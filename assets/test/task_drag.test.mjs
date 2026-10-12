import assert from "node:assert/strict"
import {readFileSync} from "node:fs"
import vm from "node:vm"
import test from "node:test"
import {environment} from "./drag_dom.mjs"

function setup(sourceIndex = 0, targetIndex = 1) {
  const env = environment()
  const context = vm.createContext(env)
  // Execute the installed dependency, including real destroy/_onDrop/_nulling.
  vm.runInContext(readFileSync(new URL("../node_modules/sortablejs/Sortable.js", import.meta.url), "utf8"), context)
  vm.runInContext(readFileSync(new URL("../js/task_drag.js", import.meta.url), "utf8")
    .replace('import Sortable from "sortablejs"', "")
    .replaceAll("export const ", "globalThis."), context)
  const {document, Sortable, TaskDrag} = context
  const board = document.createElement("main")
  document.body.appendChild(board)
  const lists = ["backlog", "today", "retry"].map(kind => {
    const list = document.createElement("div"); list.dataset.taskList = kind; board.appendChild(list); return list
  })
  const items = ["1", "2"].map(id => {
    const item = document.createElement("article"); item.dataset.taskId = id
    if (id === "1") {
      item.setAttribute("class", "task-card task-drag-chosen")
      item.setAttribute("style", "transform: scale(1);will-change: opacity")
    }
    const handle = document.createElement("button"); handle.dataset.dragHandle = ""; item.appendChild(handle)
    lists[sourceIndex].appendChild(item); return item
  })
  const empty = document.createElement("p"); lists[1].appendChild(empty)
  const unrelated = document.createElement("aside"); unrelated.setAttribute("class", "task-drag-preview"); document.body.appendChild(unrelated)
  const original = lists.map(list => [...list.children])
  const attributes = items.map(item => [item.getAttribute("class"), item.getAttribute("style")])
  const events = []
  const baselineListeners = [...document.listeners.values()].reduce((n, listeners) => n + listeners.size, 0)
  const hook = Object.assign({el: board, pushEvent(name, payload, reply) {
    assertRestored(); events.push({name, payload, reply})
  }}, TaskDrag)
  hook.mounted()
  function assertRestored() {
    lists.forEach((list, i) => assert.deepEqual(list.children, original[i]))
    items.forEach((item, i) => assert.deepEqual([item.getAttribute("class"), item.getAttribute("style")], attributes[i]))
    assert.deepEqual(document.body.children, [board, unrelated])
    assert.equal(board.dataset.dragging, undefined)
    lists.forEach(list => assert.equal(list.dataset.dropAllowed, undefined))
  }
  function start(attachClone = true) {
    const item = items[0], source = hook.sortables[sourceIndex]
    const event = {type: "mousedown", target: item.children[0], clientX: 10, clientY: 10, button: 0, cancelable: true, preventDefault() {}, stopPropagation() {}}
    // Capture precedes Sortable's list listener, as in DOM propagation.
    board.dispatchEvent(event)
    source._onTapStart(event)
    source._onDragStart(event, true)
    source._dragStarted(true, event)
    assert.ok(Sortable.ghost)
    assert.equal(Sortable.ghost.parentNode, document.body)
    // Also exercise an attached clone; default removeCloneOnHide usually detaches it.
    if (attachClone) lists[sourceIndex].appendChild(Sortable.clone)
    lists[targetIndex].appendChild(item)
    return {source, event, item, ghost: Sortable.ghost, clone: Sortable.clone}
  }
  return {...env, hook, lists, items, events, start, assertRestored, Sortable, baselineListeners}
}

for (const cancel of ["patch", "disconnect"]) {
  test(`${cancel} cancels fallback drag, restores original nodes and permits a later drop`, async () => {
    const f = setup()
    const {ghost, clone} = f.start()
    // Real animation code schedules a late style reset on a neighboring item.
    f.hook.sortables[0].animate(f.items[1], {top: 40, left: 0}, {top: 0, left: 0}, 150)
    if (cancel === "patch") f.hook.onPatchStart()
    else f.hook.disconnected()
    assert.equal(ghost.parentNode, null)
    assert.equal(clone.parentNode, null)
    f.assertRestored()
    assert.equal(f.events.length, 0)
    assert.equal(f.Sortable.dragged, null)
    assert.equal(f.Sortable.ghost, null)
    assert.equal(f.Sortable.clone, null)
    assert.equal(f.hook.gestureState, null)
    assert.equal(f.hook.source, null)
    assert.equal(f.timers.size, 0)
    assert.equal([...f.document.listeners.values()].reduce((n, listeners) => n + listeners.size, 0), f.baselineListeners + 5)
    f.hook.cancelGesture()
    f.assertRestored()
    f.hook.onPatchEnd()
    if (cancel === "disconnect") {
      assert.ok(f.hook.sortables.every(sortable => sortable.option("disabled")))
      f.hook.reconnected()
    }
    assert.ok(f.hook.sortables.every(sortable => !sortable.option("disabled")))
    const {source, event} = f.start(false)
    source._onDrop(event)
    await Promise.resolve()
    assert.equal(f.events.length, 1)
    assert.equal(f.events[0].name, "move_task")
    assert.deepEqual(JSON.parse(JSON.stringify(f.events[0].payload)), {task_id: "1", from: "backlog", to: "today", orders: {backlog: ["2"], today: ["1"]}})
    assert.equal(f.hook.pending, true)
    assert.ok(f.hook.sortables.every(sortable => sortable.option("disabled")))
    f.events[0].reply({error: "rejected"})
    assert.equal(f.hook.pending, false)
    f.hook.destroyed()
    f.assertRestored()
    for (const target of [f.hook.el, f.window, ...f.lists]) assert.ok([...target.listeners.values()].every(listeners => !listeners.size))
    assert.equal([...f.document.listeners.values()].reduce((n, listeners) => n + listeners.size, 0), f.baselineListeners)
  })
}

test("cancellation without a gesture and repeated destruction preserve legitimate nodes", () => {
  const f = setup()
  f.hook.cancelGesture()
  f.hook.cancelGesture()
  f.hook.destroyed()
  f.assertRestored()
  assert.equal(f.events.length, 0)
})

test("patch cancels a delayed touch press before choose and clears its timer", () => {
  const f = setup()
  const event = {type: "touchstart", target: f.items[0].children[0], cancelable: true,
    touches: [{target: f.items[0].children[0], clientX: 10, clientY: 10}]}
  f.hook.el.dispatchEvent(event)
  f.hook.sortables[0]._onTapStart(event)
  assert.ok(f.timers.size > 0)
  assert.equal(f.hook.snapshot, undefined)
  f.hook.onPatchStart()
  f.assertRestored()
  assert.equal(f.timers.size, 0)
  assert.equal(f.events.length, 0)
  f.hook.destroyed()
})

test("a stale reply after disconnect cannot unlock a new pending drop", () => {
  const f = setup()
  let drag = f.start(false)
  drag.source._onDrop(drag.event)
  const staleReply = f.events[0].reply
  f.hook.disconnected()
  f.hook.onPatchEnd()
  const event = {type: "mousedown", target: f.items[0].children[0], button: 0, cancelable: true}
  f.hook.el.dispatchEvent(event)
  f.hook.sortables[0]._onTapStart(event)
  assert.equal(f.Sortable.dragged, null)
  assert.equal(f.hook.gestureState, null)
  f.hook.reconnected()
  drag = f.start(false)
  drag.source._onDrop(drag.event)
  assert.equal(f.events.length, 2)
  staleReply({})
  assert.equal(f.hook.pending, true)
  f.events[1].reply({})
  assert.equal(f.hook.pending, false)
  f.hook.destroyed()
})

for (const [source, target, permitted] of [[2, 0, true], [0, 2, false], [1, 2, false]]) {
  test(`transition ${source} to ${target} validates target and restores nodes once`, () => {
    const f = setup(source, target)
    const from = f.lists[source], to = f.lists[target]
    const sortable = f.hook.sortables[source]
    assert.equal(sortable.option("onMove")({from, to}), permitted)
    const drag = f.start(false)
    assert.equal(to.dataset.dropAllowed, String(permitted))
    drag.source._onDrop(drag.event)
    f.hook.drop({})
    f.assertRestored()
    assert.equal(f.events.length, permitted ? 1 : 0)
    if (permitted) {
      assert.deepEqual(JSON.parse(JSON.stringify(f.events[0].payload)), {task_id: "1", from: "retry", to: "backlog", orders: {retry: ["2"], backlog: ["1"]}})
      f.events[0].reply({error: "rejected"})
      assert.equal(f.hook.pending, false)
    }
    f.hook.destroyed()
  })
}

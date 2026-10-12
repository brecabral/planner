import Sortable from "sortablejs"

const allowed = (from, to) => from === to ||
  ((from === "backlog" || from === "retry") && to === "today") ||
  ((from === "today" || from === "retry") && to === "backlog")

// Patch notifications run before streams touch any of the temporarily moved nodes.
export const taskDragDOM = {
  onPatchStart() { document.getElementById("planning-board")?.dispatchEvent(new Event("planner:patch-start")) },
  onPatchEnd() { document.getElementById("planning-board")?.dispatchEvent(new Event("planner:patch-end")) },
}

export const TaskDrag = {
  mounted() {
    this.pending = false
    this.offline = false
    this.generation = 0
    this.sortables = []
    // Capture before Sortable sets will-change (which happens before onChoose).
    this.onPress = event => {
      if (this.pending || this.offline || this.gestureState ||
          (event.button != null && event.button !== 0)) return
      const item = event.target.closest("[data-drag-handle]")?.closest("[data-task-id]")
      if (!item || !this.lists.includes(item.parentElement)) return
      this.source = item.parentElement
      this.gestureState = this.lists.flatMap(list => [...list.children]).map(node => ({
        node,
        attributes: ["class", "style", "draggable"].map(name => [name, node.getAttribute(name)]),
        descendants: [...node.querySelectorAll("[draggable], a, img")].map(child => [child, child.getAttribute("draggable")]),
      }))
      this.bodyUserSelect = document.body.style.userSelect
    }
    this.onRelease = () => queueMicrotask(() => { if (!this.snapshot) this.restore() })
    this.pressEvents = ["pointerdown", "mousedown", "touchstart"]
    this.releaseEvents = ["pointerup", "pointercancel", "mouseup", "touchend", "touchcancel"]
    this.pressEvents.forEach(name => this.el.addEventListener(name, this.onPress, true))
    this.releaseEvents.forEach(name => document.addEventListener(name, this.onRelease, true))
    this.onPatchStart = () => this.cancelGesture()
    this.onPatchEnd = () => { this.install(); this.syncDisabled() }
    this.onSubmit = event => {
      if (this.pending || this.offline || this.snapshot) {
        event.preventDefault()
        event.stopImmediatePropagation()
      }
    }
    this.onLoadingStart = ({detail}) => {
      if (detail.kind === "element" && this.el.contains(detail.target)) {
        this.loadingTarget = detail.target
        this.pending = true
        this.syncDisabled()
      }
    }
    this.onLoadingStop = ({detail}) => {
      if (detail.kind === "element" && this.loadingTarget === detail.target) {
        this.loadingTarget = null
        this.pending = false
        this.syncDisabled()
      }
    }
    this.el.addEventListener("planner:patch-start", this.onPatchStart)
    this.el.addEventListener("planner:patch-end", this.onPatchEnd)
    this.el.addEventListener("submit", this.onSubmit, true)
    window.addEventListener("phx:page-loading-start", this.onLoadingStart)
    window.addEventListener("phx:page-loading-stop", this.onLoadingStop)
    this.install()
  },
  install() {
    if (this.sortables.length) return
    this.lists = [...this.el.querySelectorAll("[data-task-list]")]
    this.sortables = this.lists.map(list => new Sortable(list, {
      group: {
        name: "planner-tasks",
        pull: true,
        put: (to, from) => !this.pending && !this.offline &&
          allowed(from.el.dataset.taskList, to.el.dataset.taskList),
      },
      draggable: "[data-task-id]",
      handle: "[data-drag-handle]",
      animation: window.matchMedia("(prefers-reduced-motion: reduce)").matches ? 0 : 150,
      delay: 200,
      delayOnTouchOnly: true,
      touchStartThreshold: 4,
      forceFallback: true,
      fallbackOnBody: true,
      fallbackTolerance: 3,
      scroll: true,
      bubbleScroll: true,
      emptyInsertThreshold: 24,
      ghostClass: "task-drag-placeholder",
      chosenClass: "task-drag-chosen",
      fallbackClass: "task-drag-preview",
      onChoose: event => {
        this.source = event.from
        this.snapshot = this.lists.map(el => [el, [...el.childNodes]])
        this.el.dataset.dragging = "true"
        this.lists.forEach(el => {
          el.dataset.dropAllowed = String(allowed(event.from.dataset.taskList, el.dataset.taskList))
        })
      },
      onUnchoose: () => {
        // A press released before dragging has no onEnd event.
        queueMicrotask(() => { if (this.snapshot) this.restore() })
      },
      onMove: event => !this.pending && !this.offline &&
        allowed(event.from.dataset.taskList, event.to.dataset.taskList),
      onEnd: event => this.drop(event),
    }))
    this.syncDisabled()
  },
  restore() {
    // Move the same nodes back, including empty-state nodes; never clone a stream.
    this.snapshot?.forEach(([list, nodes]) => nodes.forEach(node => list.appendChild(node)))
    this.snapshot = null
    this.gestureState?.forEach(({node, attributes, descendants}) => {
      // Sortable's animation timers survive destroy(); stop them before restoring styles.
      clearTimeout(node.animated)
      clearTimeout(node.animationResetTimer)
      node.animated = node.animatingX = node.animatingY = false
      node.animationResetTimer = null
      node.prevFromRect = node.fromRect = node.prevToRect = node.toRect = null
      node.thisAnimationDuration = null
      attributes.forEach(([name, value]) => {
        if (value === null) node.removeAttribute(name)
        else node.setAttribute(name, value)
      })
      descendants.forEach(([child, value]) => {
        if (value === null) child.removeAttribute("draggable")
        else child.setAttribute("draggable", value)
      })
    })
    if (this.gestureState) document.body.style.userSelect = this.bodyUserSelect
    this.gestureState = null
    this.bodyUserSelect = null
    this.source = null
    delete this.el.dataset.dragging
    this.lists.forEach(list => delete list.dataset.dropAllowed)
  },
  drop(event) {
    if (!this.snapshot) return
    const from = event.from.dataset.taskList
    const to = event.to.dataset.taskList
    const orders = Object.fromEntries([...new Set([event.from, event.to])].map(list => [
      list.dataset.taskList,
      [...list.querySelectorAll(":scope > [data-task-id]")].map(node => node.dataset.taskId),
    ]))
    const changed = event.from !== event.to || event.oldDraggableIndex !== event.newDraggableIndex
    this.restore()
    if (!changed || this.pending || this.offline || !allowed(from, to)) return
    this.pending = true
    this.syncDisabled()
    const generation = this.generation
    this.pushEvent("move_task", {task_id: event.item.dataset.taskId, from, to, orders}, () => {
      if (generation !== this.generation) return
      this.pending = false
      this.syncDisabled()
    })
  },
  syncDisabled() {
    const disabled = this.pending || this.offline
    this.el.dataset.movementDisabled = String(disabled)
    this.el.setAttribute("aria-busy", String(this.pending))
    this.sortables.forEach(sortable => sortable.option("disabled", disabled))
  },
  cancelGesture() {
    // destroy() calls _onDrop without an event: it clears static references but
    // skips ghost/clone removal. Keep only artifacts belonging to our gesture.
    const ownsDrag = this.gestureState?.some(({node}) => node === Sortable.dragged)
    const artifacts = ownsDrag ? [Sortable.ghost, Sortable.clone] : []
    // Destroy the source first to stop delayed starts, listeners and scrolling,
    // without firing onEnd or submitting a command.
    if (this.sortables.length) {
      this.sortables.forEach(sortable => {
        // Flush the library's private animation callback timer through its API.
        sortable.option("animation", 0)
        sortable.animateAll()
      })
      const source = this.sortables.find(sortable => sortable.el === this.source)
      source?.destroy()
      this.sortables.filter(sortable => sortable !== source).forEach(sortable => sortable.destroy())
      this.sortables = []
    }
    artifacts.forEach(node => node?.remove())
    this.restore()
  },
  disconnected() {
    this.offline = true
    this.loadingTarget = null
    this.generation += 1
    this.cancelGesture()
    this.syncDisabled()
  },
  reconnected() {
    this.offline = false
    this.pending = false
    this.install()
    this.syncDisabled()
  },
  destroyed() {
    this.generation += 1
    this.cancelGesture()
    this.el.removeEventListener("planner:patch-start", this.onPatchStart)
    this.el.removeEventListener("planner:patch-end", this.onPatchEnd)
    this.el.removeEventListener("submit", this.onSubmit, true)
    window.removeEventListener("phx:page-loading-start", this.onLoadingStart)
    window.removeEventListener("phx:page-loading-stop", this.onLoadingStop)
    this.pressEvents.forEach(name => this.el.removeEventListener(name, this.onPress, true))
    this.releaseEvents.forEach(name => document.removeEventListener(name, this.onRelease, true))
  },
}

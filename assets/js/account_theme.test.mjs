import assert from "node:assert/strict"
import test from "node:test"
import {readFile} from "node:fs/promises"

const source = await readFile(new URL("./account_theme.js", import.meta.url), "utf8")
const {AccountTheme} = await import(`data:text/javascript;base64,${Buffer.from(source).toString("base64")}`)

function fixture(theme = "planner") {
  const documentListeners = {}
  globalThis.document = {
    documentElement: {dataset: {theme: "planner"}},
    addEventListener: (name, callback) => { documentListeners[name] = callback },
    removeEventListener: name => { delete documentListeners[name] },
  }
  globalThis.localStorage = {getItem() { throw new Error("Global preferences must not be read") }}
  const select = {value: theme, disabled: false, focus() {}}
  const options = {hidden: true}
  const toggle = {setAttribute() {}, focus() { this.focused = true }, contains: target => target === toggle}
  const status = {hidden: true}
  const listeners = {}
  const requests = []
  const hook = {
    el: {
      dataset: {theme},
      querySelector: selector => ({select, "#theme-saving": status, "#theme-toggle": toggle, "#theme-options": options, "#theme-error": hook.error})[selector],
      contains: target => [select, toggle].includes(target),
      addEventListener: (name, callback) => { listeners[name] = callback },
      removeEventListener: name => { delete listeners[name] },
      setAttribute() {},
    },
    pushEvent: (name, payload, callback) => requests.push({name, payload, callback}),
  }
  AccountTheme.mounted.call(hook)
  return {hook, select, status, requests, options, toggle, documentListeners, change: () => listeners.change({target: select})}
}

test("server theme controls mount, patches, reconnect and leaving the account", () => {
  const {hook} = fixture("planner_dark")
  assert.equal(document.documentElement.dataset.theme, "planner_dark")
  AccountTheme.updated.call(hook)
  assert.equal(document.documentElement.dataset.theme, "planner_dark")
  document.documentElement.dataset.theme = "planner"
  AccountTheme.reconnected.call(hook)
  assert.equal(document.documentElement.dataset.theme, "planner_dark")
  hook.el.dataset.theme = "planner"
  AccountTheme.updated.call(hook)
  assert.equal(document.documentElement.dataset.theme, "planner")
  AccountTheme.destroyed.call(hook)
  assert.equal(document.documentElement.dataset.theme, "planner")
})

test("selection waits for persistence, prevents repeats and restores rejected choices", () => {
  const {hook, select, status, requests, change} = fixture()
  select.value = "planner_dark"
  change()
  assert.equal(requests.length, 1)
  assert.deepEqual(requests[0].payload, {theme_code: "planner_dark"})
  assert.equal(document.documentElement.dataset.theme, "planner")
  assert.equal(select.disabled, true)
  assert.equal(status.hidden, false)
  change()
  assert.equal(requests.length, 1)
  hook.error = {}
  requests[0].callback()
  assert.equal(select.value, "planner")
  assert.equal(select.disabled, false)
  assert.equal(status.hidden, true)
  select.value = "planner_dark"
  change()
  hook.error = null
  hook.el.dataset.theme = "planner_dark"
  AccountTheme.updated.call(hook)
  requests[1].callback()
  assert.equal(select.value, "planner_dark")
  assert.equal(document.documentElement.dataset.theme, "planner_dark")
})

test("disconnect blocks changes and reconnect discards stale responses", () => {
  const {hook, select, requests, change} = fixture()
  select.value = "planner_dark"
  change()
  AccountTheme.disconnected.call(hook)
  assert.equal(select.disabled, true)
  change()
  assert.equal(requests.length, 1)
  AccountTheme.reconnected.call(hook)
  assert.equal(select.disabled, false)
  select.value = "planner_dark"
  change()
  requests[0].callback()
  assert.equal(select.disabled, true)
  hook.el.dataset.theme = "planner_dark"
  requests[1].callback()
  assert.equal(select.disabled, false)
  assert.equal(document.documentElement.dataset.theme, "planner_dark")
})


test("theme menu closes without writing, restores Escape focus and stays open on failure", () => {
  const {hook, toggle, options, documentListeners, select, change, requests} = fixture()
  const click = target => documentListeners.click({target})
  assert.equal(options.hidden, true)
  click(toggle)
  assert.equal(options.hidden, false)
  click(toggle)
  assert.equal(options.hidden, true)
  click(toggle)
  click({})
  assert.equal(options.hidden, true)
  click(toggle)
  documentListeners.keydown({key: "Escape", preventDefault() {}, stopPropagation() {}})
  assert.equal(options.hidden, true)
  assert.equal(toggle.focused, true)
  assert.equal(requests.length, 0)
  click(toggle)
  select.value = "planner_dark"
  change()
  hook.error = {}
  requests[0].callback()
  assert.equal(options.hidden, false)
  assert.equal(select.value, "planner")
  hook.error = null
  select.value = "planner_dark"
  change()
  hook.el.dataset.theme = "planner_dark"
  requests[1].callback()
  assert.equal(options.hidden, true)
  AccountTheme.destroyed.call(hook)
  assert.deepEqual(documentListeners, {})
})

import assert from "node:assert/strict"
import test from "node:test"
import {readFile} from "node:fs/promises"

const source = await readFile(new URL("./account_theme.js", import.meta.url), "utf8")
const {AccountTheme} = await import(`data:text/javascript;base64,${Buffer.from(source).toString("base64")}`)

function fixture(theme = "planner") {
  globalThis.document = {documentElement: {dataset: {theme: "planner"}}}
  globalThis.localStorage = {getItem() { throw new Error("Global preferences must not be read") }}
  const select = {value: theme, disabled: false}
  const status = {hidden: true}
  const listeners = {}
  const requests = []
  const hook = {
    el: {
      dataset: {theme},
      querySelector: selector => selector === "select" ? select : status,
      addEventListener: (name, callback) => { listeners[name] = callback },
      removeEventListener: name => { delete listeners[name] },
      setAttribute() {},
    },
    pushEvent: (name, payload, callback) => requests.push({name, payload, callback}),
  }
  AccountTheme.mounted.call(hook)
  return {hook, select, status, requests, change: () => listeners.change({target: select})}
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
  requests[0].callback()
  assert.equal(select.value, "planner")
  assert.equal(select.disabled, false)
  assert.equal(status.hidden, true)
  select.value = "planner_dark"
  change()
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

import assert from "node:assert/strict"
import test from "node:test"
import {readFile} from "node:fs/promises"

const source = await readFile(new URL("./account_theme.js", import.meta.url), "utf8")
const {AccountTheme} = await import(`data:text/javascript;base64,${Buffer.from(source).toString("base64")}`)

test("server theme controls mount, patches, reconnect and leaving the account", () => {
  globalThis.document = {documentElement: {dataset: {theme: "planner"}}}
  globalThis.localStorage = {getItem() { throw new Error("Global preferences must not be read") }}
  const hook = {el: {dataset: {theme: "planner_dark"}}}
  AccountTheme.mounted.call(hook)
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
  delete globalThis.document
  delete globalThis.localStorage
})

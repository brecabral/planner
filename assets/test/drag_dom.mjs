// Minimal DOM for Sortable's lifecycle, not a layout or browser simulation.
const styleDeclaration = values => new Proxy(values, {
  has: () => true,
  get: (target, name) => target[name] ?? "",
})

export class Element {
  constructor(name = "div", document) {
    this.nodeName = name.toUpperCase()
    this.nodeType = 1
    this.ownerDocument = document
    this.childNodes = []
    this.dataset = {}
    this.attributes = new Map()
    this.style = styleDeclaration({})
    this.listeners = new Map()
    this.classList = {
      add: name => this.setAttribute("class", [...new Set([...this.classes(), name])].join(" ")),
      remove: name => this.setAttribute("class", this.classes().filter(value => value !== name).join(" ")),
      contains: name => this.classes().includes(name),
    }
  }
  classes() { return (this.getAttribute("class") || "").split(" ").filter(Boolean) }
  get children() { return this.childNodes }
  get parentElement() { return this.parentNode }
  get nextSibling() { return this.parentNode?.children[this.parentNode.children.indexOf(this) + 1] }
  get previousElementSibling() { return this.parentNode?.children[this.parentNode.children.indexOf(this) - 1] }
  get firstElementChild() { return this.children[0] }
  get lastElementChild() { return this.children.at(-1) }
  get className() { return this.getAttribute("class") || "" }
  set className(value) { this.setAttribute("class", value) }
  setAttribute(name, value) {
    this.attributes.set(name, String(value))
    if (name === "style") this.style = styleDeclaration(Object.fromEntries(String(value).split(";").filter(Boolean).map(pair => pair.split(":").map(s => s.trim()))))
  }
  getAttribute(name) {
    if (name === "style" && Object.keys(this.style).length) return Object.entries(this.style).map(([k, v]) => `${k}: ${v}`).join(";")
    return this.attributes.get(name) ?? null
  }
  removeAttribute(name) { this.attributes.delete(name); if (name === "style") this.style = styleDeclaration({}) }
  appendChild(node) { node.remove(); this.childNodes.push(node); node.parentNode = this; return node }
  removeChild(node) { this.childNodes.splice(this.childNodes.indexOf(node), 1); node.parentNode = null; return node }
  insertBefore(node, next) { if (!next) return this.appendChild(node); node.remove(); this.childNodes.splice(this.childNodes.indexOf(next), 0, node); node.parentNode = this; return node }
  remove() { this.parentNode?.removeChild(this) }
  contains(node) { return node === this || this.children.some(child => child.contains(node)) }
  matches(selector) {
    if (selector === "*") return true
    if (selector === "[data-task-list]") return this.dataset.taskList !== undefined
    if (selector === "[data-task-id]") return this.dataset.taskId !== undefined
    if (selector === "[data-drag-handle]") return this.dataset.dragHandle !== undefined
    if (selector === "[draggable]") return this.attributes.has("draggable")
    return selector.toUpperCase() === this.nodeName
  }
  closest(selector) { return this.matches(selector) ? this : this.parentNode?.closest(selector) }
  querySelectorAll(selector) {
    if (selector.includes(",")) return [...new Set(selector.split(",").flatMap(part => this.querySelectorAll(part.trim()))) ]
    if (selector.startsWith(":scope > ")) return this.children.filter(child => child.matches(selector.slice(9)))
    return this.children.flatMap(child => [...(child.matches(selector) ? [child] : []), ...child.querySelectorAll(selector)])
  }
  getElementsByTagName(name) { return this.querySelectorAll(name) }
  getBoundingClientRect() { return {top: 0, left: 0, right: 100, bottom: 40, width: 100, height: 40} }
  cloneNode(deep) {
    const node = new Element(this.nodeName, this.ownerDocument)
    this.attributes.forEach((value, key) => node.setAttribute(key, value))
    node.style = styleDeclaration({...this.style})
    node.dataset = {...this.dataset}
    if (deep) this.children.forEach(child => node.appendChild(child.cloneNode(true)))
    return node
  }
  addEventListener(name, fn, options) { const listeners = this.listeners.get(name) || new Map(); listeners.set(fn, options); this.listeners.set(name, listeners) }
  removeEventListener(name, fn) { this.listeners.get(name)?.delete(fn) }
  dispatchEvent(event) { for (const fn of this.listeners.get(event.type)?.keys() || []) typeof fn === "function" ? fn(event) : fn.handleEvent(event) }
}

export function environment() {
  const document = new Element("document")
  document.createElement = name => new Element(name, document)
  document.createEvent = () => ({initEvent(type) { this.type = type }})
  document.documentElement = document.createElement("html")
  document.body = document.createElement("body")
  document.appendChild(document.documentElement).appendChild(document.body)
  document.scrollingElement = document.documentElement
  const window = new Element("window")
  Object.assign(window, {document, navigator: {userAgent: "test"}, devicePixelRatio: 1,
    matchMedia: () => ({matches: false}), getSelection: () => ({removeAllRanges() {}}),
    getComputedStyle: el => ({...el.style, getPropertyValue: name => el.style[name] || ""}),
  })
  document.defaultView = window
  const timers = new Map()
  let id = 0
  const setTimeout = fn => { timers.set(++id, fn); return id }
  const clearTimeout = id => timers.delete(id)
  class Event { constructor(type) { this.type = type } }
  return {document, window, navigator: window.navigator, Element, HTMLElement: Element, Event, CustomEvent: Event,
    setTimeout, clearTimeout, setInterval: setTimeout, clearInterval: clearTimeout, timers,
    queueMicrotask,
  }
}

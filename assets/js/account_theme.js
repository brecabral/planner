const setOpen = (hook, open, restoreFocus = false) => {
  hook.open = open
  hook.el.querySelector("#theme-options").hidden = !open
  hook.el.querySelector("#theme-toggle").setAttribute("aria-expanded", String(open))
  if (restoreFocus) hook.el.querySelector("#theme-toggle").focus()
}

const applyTheme = hook => {
  const theme = hook.el.dataset.theme
  document.documentElement.dataset.theme = theme
  hook.el.querySelector("select").value = theme
}

const setPending = (hook, pending) => {
  hook.pending = pending
  hook.el.querySelector("select").disabled = pending || hook.offline
  hook.el.querySelector("#theme-saving").hidden = !pending
  hook.el.setAttribute("aria-busy", String(pending))
}

export const AccountTheme = {
  mounted() {
    this.generation = 0
    this.offline = false
    setOpen(this, false)
    this.onClick = event => {
      if (this.el.querySelector("#theme-toggle").contains(event.target)) {
        setOpen(this, !this.open)
        if (this.open) this.el.querySelector("select").focus()
      } else if (!this.el.contains(event.target)) {
        setOpen(this, false)
      }
    }
    this.onKeydown = event => {
      if (event.key === "Escape" && this.open) {
        event.preventDefault()
        event.stopPropagation()
        setOpen(this, false, true)
      }
    }
    document.addEventListener("click", this.onClick)
    document.addEventListener("keydown", this.onKeydown, true)
    applyTheme(this)
    setPending(this, false)
    this.onChange = event => {
      if (event.target !== this.el.querySelector("select") || this.pending || this.offline) return
      const generation = ++this.generation
      const theme = event.target.value
      setPending(this, true)
      this.pushEvent("select_theme", {theme_code: theme}, () => {
        if (generation !== this.generation) return
        applyTheme(this)
        setPending(this, false)
        setOpen(this, !!this.el.querySelector("#theme-error"), !this.el.querySelector("#theme-error"))
      })
    }
    this.el.addEventListener("change", this.onChange)
  },
  updated() {
    applyTheme(this)
    setPending(this, this.pending)
    setOpen(this, this.open)
  },
  disconnected() {
    this.generation++
    this.offline = true
    applyTheme(this)
    setPending(this, false)
  },
  reconnected() {
    this.offline = false
    applyTheme(this)
    setPending(this, false)
  },
  destroyed() {
    this.generation++
    document.removeEventListener("click", this.onClick)
    document.removeEventListener("keydown", this.onKeydown, true)
    this.el.removeEventListener("change", this.onChange)
    document.documentElement.dataset.theme = "planner"
  },
}

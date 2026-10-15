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
      })
    }
    this.el.addEventListener("change", this.onChange)
  },
  updated() {
    applyTheme(this)
    setPending(this, this.pending)
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
    this.el.removeEventListener("change", this.onChange)
    document.documentElement.dataset.theme = "planner"
  },
}

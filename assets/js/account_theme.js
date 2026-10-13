const applyTheme = hook => {
  document.documentElement.dataset.theme = hook.el.dataset.theme
}

export const AccountTheme = {
  mounted() { applyTheme(this) },
  updated() { applyTheme(this) },
  reconnected() { applyTheme(this) },
  destroyed() { document.documentElement.dataset.theme = "planner" },
}

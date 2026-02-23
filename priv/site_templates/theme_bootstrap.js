(() => {
  try {
    const mode = localStorage.getItem("cinder_ui:site:theme") === "dark" ? "dark" : "light";
    const root = document.documentElement;
    root.classList.toggle("dark", mode === "dark");
    root.dataset.themeMode = mode;
  } catch (_error) {}
})();

(() => {
  try {
    const mode = localStorage.getItem("eui:theme:mode") || "auto";
    const resolvedMode = mode === "auto"
      ? (window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light")
      : mode;
    const root = document.documentElement;
    root.classList.toggle("dark", resolvedMode === "dark");
    root.dataset.themeMode = mode;
  } catch (_error) {}
})();

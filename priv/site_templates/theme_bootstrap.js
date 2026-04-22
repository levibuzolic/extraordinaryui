(() => {
  try {
    const storedMode = localStorage.getItem("cui:theme:mode");
    const mode = ["light", "dark", "auto"].includes(storedMode) ? storedMode : "auto";
    const resolvedMode = mode === "auto"
      ? (window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light")
      : mode;
    const root = document.documentElement;
    root.classList.toggle("dark", resolvedMode === "dark");
    root.dataset.theme = resolvedMode;
    root.dataset.themeMode = mode;
  } catch (_error) {}
})();

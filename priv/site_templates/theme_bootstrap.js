(() => {
  const themeStorage = {
    mode: "cui:theme:mode",
    color: "cui:theme:color",
    radius: "cui:theme:radius",
  };
  const darkSidebarPresets = {
    neutral: "oklch(0.145 0 0)",
    stone: "oklch(0.147 0.004 49.25)",
    zinc: "oklch(0.141 0.005 285.823)",
    mauve: "oklch(0.129 0.042 264.695)",
    olive: "oklch(0.144 0.013 101.487)",
    mist: "oklch(0.138 0.039 265.975)",
    taupe: "oklch(0.146 0.01 49.25)",
  };
  const radiusPresets = {
    maia: "0.375rem",
    mira: "0.5rem",
    nova: "0.75rem",
    lyra: "0.875rem",
    vega: "1rem",
  };

  try {
    const storedMode = localStorage.getItem(themeStorage.mode);
    const mode = ["light", "dark", "auto"].includes(storedMode) ? storedMode : "auto";
    const storedColor = localStorage.getItem(themeStorage.color);
    const color = Object.prototype.hasOwnProperty.call(darkSidebarPresets, storedColor)
      ? storedColor
      : "neutral";
    const storedRadius = localStorage.getItem(themeStorage.radius);
    const radius = Object.prototype.hasOwnProperty.call(radiusPresets, storedRadius)
      ? storedRadius
      : "nova";
    const resolvedMode = mode === "auto"
      ? (window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light")
      : mode;
    const root = document.documentElement;
    root.classList.toggle("dark", resolvedMode === "dark");
    root.dataset.theme = resolvedMode;
    root.dataset.themeMode = mode;
    root.dataset.themeColor = color;
    root.dataset.themeRadius = radius;
    root.style.setProperty("--radius", radiusPresets[radius]);
    root.style.setProperty(
      "--sidebar",
      resolvedMode === "dark" ? darkSidebarPresets[color] : "oklch(1 0 0)",
    );
  } catch (_error) {}
})();

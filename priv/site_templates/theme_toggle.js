(() => {
  const storageKey = "cinder_ui:site:theme";
  const root = document.documentElement;
  const buttons = Array.from(document.querySelectorAll("[data-site-theme]"));
  const qs = (selector) => Array.from(document.querySelectorAll(selector));
  const escapeHtml = (value) =>
    value
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;");
  const highlightHeex = (source) => {
    let html = escapeHtml(source);
    html = html.replace(/(&lt;!--[\s\S]*?--&gt;)/g, '<span class="tok-comment">$1</span>');
    html = html.replace(/([:@A-Za-z0-9_-]+)(=)/g, '<span class="tok-attr">$1</span>$2');
    html = html.replace(/(&lt;\/?)([:A-Za-z0-9_.-]+)/g, '$1<span class="tok-tag">$2</span>');
    html = html.replace(/(&quot;[^&]*?&quot;)/g, '<span class="tok-string">$1</span>');
    html = html.replace(/(\{[^\n]*?\})/g, '<span class="tok-expr">$1</span>');
    html = html.replace(/\b(true|false|nil|do|end)\b/g, '<span class="tok-keyword">$1</span>');
    return html;
  };
  const highlightCodeBlocks = () => {
    qs("pre code").forEach((block) => {
      if (block.dataset.highlighted === "true") return;
      const source = block.textContent || "";
      if (source.trim() === "") return;
      const isHeexLike =
        source.includes("<.") || source.includes("</.") || source.includes("<:");
      block.innerHTML = isHeexLike ? highlightHeex(source) : escapeHtml(source);
      block.classList.add("code-highlight");
      block.dataset.highlighted = "true";
    });
  };

  const apply = (mode) => {
    const normalized = mode === "dark" ? "dark" : "light";
    root.classList.toggle("dark", normalized === "dark");
    root.dataset.themeMode = normalized;

    buttons.forEach((button) => {
      const active = button.dataset.siteTheme === normalized;
      button.dataset.active = active ? "true" : "false";
      button.setAttribute("aria-pressed", active ? "true" : "false");
    });
  };

  apply(root.dataset.themeMode === "dark" ? "dark" : "light");

  buttons.forEach((button) => {
    button.addEventListener("click", () => {
      const mode = button.dataset.siteTheme === "dark" ? "dark" : "light";
      try {
        localStorage.setItem(storageKey, mode);
      } catch (_error) {}
      apply(mode);
    });
  });

  highlightCodeBlocks();
})();

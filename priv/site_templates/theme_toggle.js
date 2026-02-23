(() => {
  const storageKey = "cinder_ui:site:theme";
  const root = document.documentElement;
  const buttons = Array.from(document.querySelectorAll("[data-site-theme]"));
  const qs = (selector) => Array.from(document.querySelectorAll(selector));
  const keywordPattern = /^(true|false|nil|do|end|fn|if|else|case|when|with|for|in)$/;

  const escapeHtml = (value) =>
    value
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/\"/g, "&quot;")
      .replace(/'/g, "&#39;");

  const readBalanced = (source, start, openChar, closeChar) => {
    let depth = 0;
    let i = start;
    let quote = null;

    while (i < source.length) {
      const char = source[i];

      if (quote) {
        if (char === "\\") {
          i += 2;
          continue;
        }

        if (char === quote) quote = null;
        i += 1;
        continue;
      }

      if (char === '"' || char === "'") {
        quote = char;
        i += 1;
        continue;
      }

      if (char === openChar) depth += 1;
      if (char === closeChar) {
        depth -= 1;
        if (depth === 0) {
          return { chunk: source.slice(start, i + 1), end: i + 1 };
        }
      }

      i += 1;
    }

    return { chunk: source.slice(start), end: source.length };
  };

  const highlightExpression = (expr) => {
    let out = "";
    let i = 0;

    while (i < expr.length) {
      const char = expr[i];

      if (char === "{" || char === "}") {
        out += `<span class="tok-punct">${escapeHtml(char)}</span>`;
        i += 1;
        continue;
      }

      if (char === '"' || char === "'") {
        let j = i + 1;
        while (j < expr.length) {
          if (expr[j] === "\\") {
            j += 2;
            continue;
          }
          if (expr[j] === char) {
            j += 1;
            break;
          }
          j += 1;
        }

        out += `<span class="tok-string">${escapeHtml(expr.slice(i, j))}</span>`;
        i = j;
        continue;
      }

      if (char === ":" && /[A-Za-z_]/.test(expr[i + 1] || "")) {
        let j = i + 2;
        while (j < expr.length && /[A-Za-z0-9_?!]/.test(expr[j])) j += 1;
        out += `<span class="tok-atom">${escapeHtml(expr.slice(i, j))}</span>`;
        i = j;
        continue;
      }

      if (/[0-9]/.test(char)) {
        let j = i + 1;
        while (j < expr.length && /[0-9._]/.test(expr[j])) j += 1;
        out += `<span class="tok-number">${escapeHtml(expr.slice(i, j))}</span>`;
        i = j;
        continue;
      }

      if (/[A-Za-z_]/.test(char)) {
        let j = i + 1;
        while (j < expr.length && /[A-Za-z0-9_?!]/.test(expr[j])) j += 1;
        const word = expr.slice(i, j);
        const klass = keywordPattern.test(word) ? "tok-keyword" : "tok-ident";
        out += `<span class="${klass}">${escapeHtml(word)}</span>`;
        i = j;
        continue;
      }

      if (/[=+\-*/<>!|&]/.test(char)) {
        let j = i + 1;
        while (j < expr.length && /[=+\-*/<>!|&]/.test(expr[j])) j += 1;
        out += `<span class="tok-operator">${escapeHtml(expr.slice(i, j))}</span>`;
        i = j;
        continue;
      }

      if (/[()[\],.%]/.test(char)) {
        out += `<span class="tok-punct">${escapeHtml(char)}</span>`;
        i += 1;
        continue;
      }

      out += escapeHtml(char);
      i += 1;
    }

    return `<span class="tok-expr">${out}</span>`;
  };

  const highlightTag = (tag) => {
    if (tag.startsWith("<!--")) {
      return `<span class="tok-comment">${escapeHtml(tag)}</span>`;
    }

    const closing = tag.startsWith("</");
    const selfClosing = tag.endsWith("/>");
    const closeToken = selfClosing ? "/>" : ">";

    let cursor = closing ? 2 : 1;
    let out = `<span class="tok-punct">${closing ? "&lt;/" : "&lt;"}</span>`;

    let nameEnd = cursor;
    while (nameEnd < tag.length && /[:A-Za-z0-9_.-]/.test(tag[nameEnd])) nameEnd += 1;
    const tagName = tag.slice(cursor, nameEnd);
    out += `<span class="tok-tag">${escapeHtml(tagName)}</span>`;
    cursor = nameEnd;

    while (cursor < tag.length - closeToken.length) {
      const char = tag[cursor];

      if (/\s/.test(char)) {
        out += char;
        cursor += 1;
        continue;
      }

      if (char === "{") {
        const { chunk, end } = readBalanced(tag, cursor, "{", "}");
        out += highlightExpression(chunk);
        cursor = end;
        continue;
      }

      if (char === '"' || char === "'") {
        let j = cursor + 1;
        while (j < tag.length) {
          if (tag[j] === "\\") {
            j += 2;
            continue;
          }
          if (tag[j] === char) {
            j += 1;
            break;
          }
          j += 1;
        }

        out += `<span class="tok-string">${escapeHtml(tag.slice(cursor, j))}</span>`;
        cursor = j;
        continue;
      }

      if (/[=]/.test(char)) {
        out += `<span class="tok-operator">${escapeHtml(char)}</span>`;
        cursor += 1;
        continue;
      }

      if (char === "/") {
        out += `<span class="tok-punct">/</span>`;
        cursor += 1;
        continue;
      }

      if (/[@:A-Za-z_]/.test(char)) {
        let j = cursor + 1;
        while (j < tag.length && /[@:A-Za-z0-9_.-]/.test(tag[j])) j += 1;
        out += `<span class="tok-attr">${escapeHtml(tag.slice(cursor, j))}</span>`;
        cursor = j;
        continue;
      }

      out += escapeHtml(char);
      cursor += 1;
    }

    out += `<span class="tok-punct">${closeToken === "/>" ? "/&gt;" : "&gt;"}</span>`;
    return out;
  };

  const highlightHeex = (source) => {
    let out = "";
    let i = 0;

    while (i < source.length) {
      if (source.startsWith("<!--", i)) {
        const end = source.indexOf("-->", i + 4);
        const chunk = end === -1 ? source.slice(i) : source.slice(i, end + 3);
        out += `<span class="tok-comment">${escapeHtml(chunk)}</span>`;
        i += chunk.length;
        continue;
      }

      if (source[i] === "<") {
        const tagEnd = source.indexOf(">", i + 1);
        if (tagEnd === -1) {
          out += escapeHtml(source.slice(i));
          break;
        }

        const tag = source.slice(i, tagEnd + 1);
        out += highlightTag(tag);
        i = tagEnd + 1;
        continue;
      }

      if (source[i] === "{") {
        const { chunk, end } = readBalanced(source, i, "{", "}");
        out += highlightExpression(chunk);
        i = end;
        continue;
      }

      let j = i;
      while (j < source.length && source[j] !== "<" && source[j] !== "{") j += 1;
      out += `<span class="tok-text">${escapeHtml(source.slice(i, j))}</span>`;
      i = j;
    }

    return out;
  };

  const highlightCodeBlocks = () => {
    qs("pre code").forEach((block) => {
      if (block.dataset.highlighted === "true") return;

      const source = block.textContent || "";
      if (source.trim() === "") return;

      const isHeexLike =
        source.includes("<.") || source.includes("</.") || source.includes("<:") || source.includes("</:");

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

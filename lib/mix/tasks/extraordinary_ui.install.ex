defmodule Mix.Tasks.ExtraordinaryUi.Install do
  @shortdoc "Installs Extraordinary UI assets and Tailwind dependencies"
  @moduledoc """
  Installs Extraordinary UI into a Phoenix project.

  The task performs the following steps:

  1. Copies `extraordinary_ui.css` and `extraordinary_ui.js` into your `assets/` folder.
  2. Updates `assets/css/app.css` with:
     - `@source "../../deps/extraordinary_ui";`
     - `@import "./extraordinary_ui.css";`
  3. Updates `assets/js/app.js` to merge Extraordinary UI LiveView hooks.
  4. Installs `tailwindcss-animate` using your detected or selected package manager.

  ## Options

    * `--assets-path` - path to the assets directory (default: `assets`)
    * `--package-manager` - `npm`, `pnpm`, `yarn`, or `bun`
    * `--style` - one of `nova`, `maia`, `lyra`, `mira`, `vega` (metadata only)
    * `--skip-existing` - do not overwrite Extraordinary UI generated files if they already exist

  ## Example

      mix extraordinary_ui.install --package-manager pnpm --style nova
  """

  use Mix.Task

  @template_dir Path.expand("../../../priv/templates", __DIR__)
  @supported_pm ~w(npm pnpm yarn bun)
  @supported_styles ~w(nova maia lyra mira vega)

  @impl true
  def run(argv) do
    {opts, _, _} =
      OptionParser.parse(argv,
        strict: [
          assets_path: :string,
          package_manager: :string,
          style: :string,
          skip_existing: :boolean,
          help: :boolean
        ]
      )

    if opts[:help] do
      Mix.shell().info(@moduledoc)
    else
      assets_path = Path.expand(opts[:assets_path] || "assets", File.cwd!())
      style = normalize_style(opts[:style])
      package_manager = normalize_package_manager(opts[:package_manager], assets_path)
      skip_existing = opts[:skip_existing] || false

      ensure_assets_dir!(assets_path)

      install_css!(assets_path, skip_existing)
      install_js!(assets_path, skip_existing)
      patch_app_css!(assets_path)
      patch_app_js!(assets_path)
      maybe_install_package!(assets_path, package_manager, "tailwindcss-animate")
      write_install_marker!(assets_path, style, skip_existing)

      Mix.shell().info("Extraordinary UI install complete (style: #{style}).")
    end
  end

  defp ensure_assets_dir!(assets_path) do
    unless File.dir?(assets_path) do
      Mix.raise("assets path not found: #{assets_path}")
    end
  end

  defp install_css!(assets_path, skip_existing) do
    src = Path.join(@template_dir, "extraordinary_ui.css")
    target = Path.join([assets_path, "css", "extraordinary_ui.css"])

    File.mkdir_p!(Path.dirname(target))
    write_generated_file!(target, File.read!(src), skip_existing, "created")
  end

  defp install_js!(assets_path, skip_existing) do
    src = Path.join(@template_dir, "extraordinary_ui.js")
    target = Path.join([assets_path, "js", "extraordinary_ui.js"])

    File.mkdir_p!(Path.dirname(target))
    write_generated_file!(target, File.read!(src), skip_existing, "created")
  end

  defp patch_app_css!(assets_path) do
    app_css_path = Path.join([assets_path, "css", "app.css"])

    base =
      if File.exists?(app_css_path) do
        File.read!(app_css_path)
      else
        "@import \"tailwindcss\";\n"
      end

    base = ensure_line(base, "@source \"../../deps/extraordinary_ui\";")
    base = ensure_line(base, "@import \"./extraordinary_ui.css\";")

    File.write!(app_css_path, base)
    Mix.shell().info("updated #{relative(app_css_path)}")
  end

  defp patch_app_js!(assets_path) do
    app_js_path = Path.join([assets_path, "js", "app.js"])

    content =
      if File.exists?(app_js_path) do
        File.read!(app_js_path)
      else
        "import { LiveSocket } from \"phoenix_live_view\"\nlet Hooks = {}\n"
      end

    content =
      content
      |> ensure_line("import { ExtraordinaryUIHooks } from \"./extraordinary_ui\"")
      |> inject_hooks_merge()

    File.write!(app_js_path, content)
    Mix.shell().info("updated #{relative(app_js_path)}")
  end

  defp inject_hooks_merge(content) do
    cond do
      String.contains?(content, "Object.assign(Hooks, ExtraordinaryUIHooks)") ->
        content

      String.contains?(content, "let Hooks = {}") ->
        String.replace(
          content,
          "let Hooks = {}",
          "let Hooks = {}\nObject.assign(Hooks, ExtraordinaryUIHooks)"
        )

      String.contains?(content, "let hooks = {}") ->
        String.replace(
          content,
          "let hooks = {}",
          "let hooks = {}\nObject.assign(hooks, ExtraordinaryUIHooks)"
        )

      true ->
        content <>
          "\nlet Hooks = window.Hooks || {}\nObject.assign(Hooks, ExtraordinaryUIHooks)\nwindow.Hooks = Hooks\n"
    end
  end

  defp ensure_line(content, line) do
    if String.contains?(content, line),
      do: content,
      else: String.trim_trailing(content) <> "\n" <> line <> "\n"
  end

  defp maybe_install_package!(assets_path, package_manager, package) do
    package_json = Path.join(assets_path, "package.json")

    if File.exists?(package_json) do
      {cmd, args} = package_command(package_manager, package)
      Mix.shell().info("running #{cmd} #{Enum.join(args, " ")}")
      {output, status} = System.cmd(cmd, args, cd: assets_path, stderr_to_stdout: true)

      if status == 0 do
        Mix.shell().info(String.trim(output))
      else
        Mix.shell().error(String.trim(output))
        Mix.raise("failed to install #{package} using #{package_manager}")
      end
    else
      Mix.shell().info("skipping npm install (no package.json found in #{relative(assets_path)})")
    end
  end

  defp package_command("npm", package), do: {"npm", ["install", "-D", package]}
  defp package_command("pnpm", package), do: {"pnpm", ["add", "-D", package]}
  defp package_command("yarn", package), do: {"yarn", ["add", "-D", package]}
  defp package_command("bun", package), do: {"bun", ["add", "-d", package]}

  defp write_install_marker!(assets_path, style, skip_existing) do
    marker_path = Path.join([assets_path, "css", ".extraordinary_ui_style"])
    write_generated_file!(marker_path, style <> "\n", skip_existing, "wrote")
  end

  defp write_generated_file!(path, content, true, verb) do
    if File.exists?(path) do
      Mix.shell().info("skipped existing #{relative(path)}")
    else
      File.write!(path, content)
      Mix.shell().info("#{verb} #{relative(path)}")
    end
  end

  defp write_generated_file!(path, content, false, verb) do
    File.write!(path, content)
    Mix.shell().info("#{verb} #{relative(path)}")
  end

  defp normalize_package_manager(nil, assets_path) do
    cond do
      File.exists?(Path.join(assets_path, "pnpm-lock.yaml")) -> "pnpm"
      File.exists?(Path.join(assets_path, "yarn.lock")) -> "yarn"
      File.exists?(Path.join(assets_path, "bun.lockb")) -> "bun"
      true -> "npm"
    end
  end

  defp normalize_package_manager(value, _assets_path) when value in @supported_pm, do: value

  defp normalize_package_manager(value, _assets_path) do
    Mix.raise(
      "unsupported package manager: #{inspect(value)}. Expected one of #{Enum.join(@supported_pm, ", ")}"
    )
  end

  defp normalize_style(nil), do: "nova"
  defp normalize_style(style) when style in @supported_styles, do: style

  defp normalize_style(style) do
    Mix.raise(
      "unsupported style: #{inspect(style)}. Expected one of #{Enum.join(@supported_styles, ", ")}"
    )
  end

  defp relative(path), do: Path.relative_to(path, File.cwd!())
end

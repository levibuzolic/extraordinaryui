defmodule DemoApp.SiteRuntime do
  @moduledoc false

  alias CinderUI.Docs.Catalog
  require Logger

  @repo_root Path.expand("../../../../", __DIR__)
  @site_dir Path.expand("../../../../dist/site", __DIR__)
  @built_docs_assets_dir Path.expand("../../../../dist/site/docs/assets", __DIR__)
  @docs_assets_dir Path.expand("../../../../dev/assets/docs", __DIR__)
  @site_assets_dir Path.expand("../../../../dev/assets/site", __DIR__)
  @catalog_sections_key {__MODULE__, :catalog_sections}
  @catalog_count_key {__MODULE__, :catalog_count}

  def site_dir, do: @site_dir

  def docs_site_js do
    [Path.join(@site_assets_dir, "shared.js"), Path.join(@docs_assets_dir, "site.js")]
    |> Enum.map_join(";\n\n", &File.read!/1)
    |> Kernel.<>(";\n")
  end

  def ensure_site_built! do
    unless File.exists?(Path.join(@site_dir, "index.html")) do
      rebuild_site!()
    end

    :ok
  end

  def catalog_sections do
    case :persistent_term.get(@catalog_sections_key, :missing) do
      :missing ->
        Logger.debug("[docs-cache] catalog_sections miss")
        sections = Catalog.sections()
        :persistent_term.put(@catalog_sections_key, sections)
        sections

      sections ->
        Logger.debug("[docs-cache] catalog_sections hit")
        sections
    end
  end

  def catalog_component_count do
    case :persistent_term.get(@catalog_count_key, :missing) do
      :missing ->
        Logger.debug("[docs-cache] catalog_component_count miss")
        count = catalog_sections() |> Enum.flat_map(& &1.entries) |> length()
        :persistent_term.put(@catalog_count_key, count)
        count

      count ->
        Logger.debug("[docs-cache] catalog_component_count hit")
        count
    end
  end

  def clear_catalog_cache do
    :persistent_term.erase(@catalog_sections_key)
    :persistent_term.erase(@catalog_count_key)
    Logger.debug("[docs-cache] cache cleared")
    :ok
  end

  def rebuild_site! do
    {output, status} =
      System.cmd("mix", ["cinder_ui.docs.build"],
        cd: @repo_root,
        stderr_to_stdout: true
      )

    if status != 0 do
      raise "failed to rebuild docs site:\n\n#{output}"
    end

    clear_catalog_cache()

    :ok
  end

  def resolve_request_path(path_segments) when is_list(path_segments) do
    relative_segments = Enum.reject(path_segments, &(&1 in ["", "."]))

    relative =
      case relative_segments do
        [] -> ""
        _ -> Path.join(relative_segments)
      end

    relative = if relative == "", do: "index.html", else: relative
    expanded = Path.expand(relative, @site_dir)

    if String.starts_with?(expanded, @site_dir) do
      if File.dir?(expanded), do: Path.join(expanded, "index.html"), else: expanded
    else
      nil
    end
  end

  def resolve_docs_asset_path(path_segments) when is_list(path_segments) do
    case relative_path(path_segments) do
      relative when is_binary(relative) ->
        relative
        |> docs_asset_lookup_dirs()
        |> resolve_in_dirs(relative)

      _ ->
        nil
    end
  end

  defp relative_path(path_segments) do
    path_segments
    |> Enum.reject(&(&1 in ["", "."]))
    |> case do
      [] -> nil
      segments -> Path.join(segments)
    end
  end

  defp docs_asset_lookup_dirs("theme.css"),
    do: [@built_docs_assets_dir, @docs_assets_dir, @site_assets_dir]

  defp docs_asset_lookup_dirs(_relative),
    do: [@docs_assets_dir, @site_assets_dir, @built_docs_assets_dir]

  defp resolve_in_dirs(directories, relative) do
    Enum.find_value(directories, &resolve_in_dir(relative, &1))
  end

  defp resolve_in_dir(relative, assets_dir) do
    expanded = Path.expand(relative, assets_dir)

    if String.starts_with?(expanded, assets_dir) and File.regular?(expanded) do
      expanded
    else
      nil
    end
  end
end

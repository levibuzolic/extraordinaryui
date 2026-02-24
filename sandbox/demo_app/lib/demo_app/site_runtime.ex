defmodule DemoApp.SiteRuntime do
  @moduledoc false

  @repo_root Path.expand("../../../../", __DIR__)
  @site_dir Path.expand("../../../../dist/site", __DIR__)
  @docs_assets_dir Path.expand("../../../../dev/assets/docs", __DIR__)
  @site_assets_dir Path.expand("../../../../dev/assets/site", __DIR__)

  def site_dir, do: @site_dir

  def docs_site_js do
    [Path.join(@site_assets_dir, "shared.js"), Path.join(@docs_assets_dir, "site.js")]
    |> Enum.map(&File.read!/1)
    |> Enum.join(";\n\n")
    |> Kernel.<>(";\n")
  end

  def ensure_site_built! do
    index_path = Path.join(@site_dir, "index.html")

    unless File.exists?(index_path) do
      rebuild_site!()
    end

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
      cond do
        File.dir?(expanded) -> Path.join(expanded, "index.html")
        true -> expanded
      end
    else
      nil
    end
  end

  def resolve_docs_asset_path(path_segments) when is_list(path_segments) do
    relative_segments = Enum.reject(path_segments, &(&1 in ["", "."]))

    relative =
      case relative_segments do
        [] -> nil
        _ -> Path.join(relative_segments)
      end

    with true <- is_binary(relative) do
      resolve_in_dir(relative, @docs_assets_dir) ||
        resolve_in_dir(relative, @site_assets_dir)
    else
      _ -> nil
    end
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

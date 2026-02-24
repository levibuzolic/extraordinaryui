defmodule DemoApp.SiteRuntime do
  @moduledoc false

  @repo_root Path.expand("../../../../", __DIR__)
  @site_dir Path.expand("../../../../dist/site", __DIR__)

  def site_dir, do: @site_dir

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
end

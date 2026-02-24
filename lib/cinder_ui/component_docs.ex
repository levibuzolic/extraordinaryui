defmodule CinderUI.ComponentDocs do
  @moduledoc false

  @spec screenshot_markdown_path(module(), atom()) :: String.t()
  defp screenshot_markdown_path(module, function) when is_atom(module) and is_atom(function) do
    "screenshots/#{component_id(module, function)}.png"
  end

  @spec component_id(module(), atom()) :: String.t()
  defp component_id(module, function) when is_atom(module) and is_atom(function) do
    module_slug =
      module
      |> Module.split()
      |> List.last()
      |> Macro.underscore()
      |> String.replace("_", "-")

    "#{module_slug}-#{function}"
  end

  @doc false
  defmacro doc(markdown) do
    updated_markdown = append_screenshot(markdown, __CALLER__)

    quote do
      @doc unquote(updated_markdown)
    end
  end

  defp append_screenshot(markdown, _env) when not is_binary(markdown), do: markdown

  defp append_screenshot(markdown, env) do
    markdown = String.replace(markdown, "doc/screenshots/", "screenshots/")

    case documented_function(env.file, env.line) do
      nil ->
        markdown

      function ->
        screenshot_path = screenshot_markdown_path(env.module, function)

        if String.contains?(markdown, screenshot_path) do
          markdown
        else
          String.trim_trailing(markdown) <>
            "\n\n## Screenshot\n\n![#{function}/1 screenshot](#{screenshot_path})\n"
        end
    end
  end

  defp documented_function(file, doc_line) do
    file
    |> File.stream!()
    |> Enum.drop(doc_line)
    |> Enum.find_value(fn line ->
      case Regex.run(~r/^\s*def\s+([a-zA-Z0-9_!?]+)\s*\(/, line, capture: :all_but_first) do
        [function_name] -> String.to_atom(function_name)
        _ -> nil
      end
    end)
  end
end

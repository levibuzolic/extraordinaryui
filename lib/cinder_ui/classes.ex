defmodule CinderUI.Classes do
  @moduledoc """
  Utilities for composing Tailwind class lists.
  """

  @doc """
  Joins classes from strings/lists while removing nil/false/empty values.
  """
  def classes(values) when is_list(values) do
    values
    |> List.flatten()
    |> Enum.filter(fn
      nil -> false
      false -> false
      "" -> false
      class when is_binary(class) -> true
      _ -> false
    end)
    |> Enum.join(" ")
  end

  def classes(value), do: classes([value])

  @doc """
  Picks a class from a map keyed by atom/string variants.
  """
  def variant(map, key, fallback \\ nil) when is_map(map) do
    Map.get(map, key) || Map.get(map, to_string(key)) || fallback
  end
end

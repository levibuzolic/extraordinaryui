defmodule ExtraordinaryUI.TestHelpers do
  @moduledoc false

  def slot(content) when is_binary(content) do
    [%{inner_block: fn _, _ -> content end}]
  end

  def slot(fun) when is_function(fun, 0) do
    [%{inner_block: fn _, _ -> fun.() end}]
  end

  def slot(content, attrs) when is_binary(content) and is_map(attrs) do
    [%{inner_block: fn _, _ -> content end} |> Map.merge(attrs)]
  end
end

ExUnit.start()

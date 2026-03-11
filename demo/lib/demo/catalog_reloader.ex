defmodule Demo.CatalogReloader do
  @moduledoc false

  use GenServer

  # Map component source files to their section ids.
  # Files outside these paths (e.g. shared modules) clear the entire cache.
  @file_to_section %{
    "lib/cinder_ui/components/actions.ex" => "actions",
    "lib/cinder_ui/components/forms.ex" => "forms",
    "lib/cinder_ui/components/layout.ex" => "layout",
    "lib/cinder_ui/components/feedback.ex" => "feedback",
    "lib/cinder_ui/components/data_display.ex" => "data-display",
    "lib/cinder_ui/components/navigation.ex" => "navigation",
    "lib/cinder_ui/components/overlay.ex" => "overlay",
    "lib/cinder_ui/components/advanced.ex" => "advanced",
    "lib/cinder_ui/icons.ex" => "icons"
  }

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    Phoenix.PubSub.subscribe(Demo.PubSub, "catalog_change")
    {:ok, :no_state}
  end

  @impl true
  def handle_info({:phoenix_live_reload, :catalog_change, path}, state) do
    case section_id_for_path(path) do
      nil ->
        Demo.SiteRuntime.clear_catalog_cache()

      section_id ->
        Demo.SiteRuntime.clear_section_cache(section_id)
    end

    {:noreply, state}
  end

  defp section_id_for_path(path) when is_binary(path) do
    Enum.find_value(@file_to_section, fn {suffix, section_id} ->
      if String.ends_with?(path, suffix), do: section_id
    end)
  end
end

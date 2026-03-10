defmodule Demo.CatalogReloader do
  @moduledoc false

  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    Phoenix.PubSub.subscribe(Demo.PubSub, "catalog_change")
    {:ok, :no_state}
  end

  @impl true
  def handle_info({:phoenix_live_reload, :catalog_change, _path}, state) do
    Demo.SiteRuntime.clear_catalog_cache()
    {:noreply, state}
  end
end

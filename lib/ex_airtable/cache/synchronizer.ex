defmodule ExAirtable.Cache.Synchronizer do
  @moduledoc """
  Run scheduled synchronization of an `ExAirtable.Cache` against the relevant Airtable base. This will be automatically spawned and linked to an `ExAirtable.Cache` when `start_link/2` is run for that cache.
  """

  defstruct cache: nil, sync_rate: nil

  @typedoc """
  A struct that contains the state for a `Cache.Synchronizer`
  """
  @type t :: %__MODULE__{
    cache: module(),
    sync_rate: integer()
  }

  use GenServer
  require Logger
  alias ExAirtable.Cache

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl GenServer
  def init(opts) do
    state = %__MODULE__{
      cache: Keyword.fetch!(opts, :cache),
      sync_rate: Keyword.fetch!(opts, :sync_rate)
    }

    send(self(), :sync)

    {:ok, state}
  end

  @impl GenServer
  def handle_info(:sync, %{cache: cache} = state) do
    Logger.debug "Synching #{inspect cache}..."
    Cache.set_all(cache, fetch(state))
    schedule(state)

    {:noreply, state}
  end

  defp fetch(state) do
    module = Cache.module_for(state.cache)
    apply(module, :list, [])
  end

  defp schedule(state) do
    Process.send_after(self(), :sync, state.sync_rate)
  end
end

defmodule ExAirtable.Table do
  @moduledoc """
  The `Table` behaviour allows you to define your own modules that use Airtables. It is a thin wrapper around `Service`, but often more convenient to use.

  ## Examples
  
      defmodule MyTable do
        use ExAirtable.Table

        def base, do: %ExAirtable.Config.Base{
          id: "your base ID",
          api_key: "your api key"
        }
        def name, do: "My Airtable Table Name"
      end

      iex> MyTable.list()
      %ExAirtable.Airtable.List{} 

      iex> MyTable.retrieve("rec123")
      %ExAirtable.Airtable.Record{} 
  """

  alias ExAirtable.{Airtable, Config, Service}

  @doc "A valid %ExAirtable.Config.Base{} config for your table"
  @callback base :: Config.Base.t()

  @doc "The name of your table within Airtable"
  @callback name() :: String.t()

  defmacro __using__(_) do
    quote do
      @behaviour ExAirtable.Table

      @doc """
      Create a record in your Airtable. See `Service.create/2` for details.
      """
      def create(%Airtable.List{} = list) do
        Service.create table(), list
      end

      @doc """
      Get all records from your Airtable. See `Service.list/3` for details.
      """
      def list(opts \\ []) do
        Service.list table(), opts
      end

      # Make list overrideable for testing mocks
      defoverridable list: 1

      @doc """
      Get a single record from your Airtable, matching by ID. See `Service.retrieve/2` for details.
      """
      def retrieve(id) when is_binary(id) do
        Service.retrieve table(), id
      end

      # Make list overrideable for testing mocks
      defoverridable retrieve: 1

      @doc """
      Utility function to return the table struct
      """
      def table() do
        %Config.Table{base: base(), name: name()}
      end
    end
  end
end

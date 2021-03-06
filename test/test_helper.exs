ExUnit.start()

defmodule ExAirtable.MockTable do
  use ExAirtable.Table

  alias ExAirtable.{Airtable, Config}

  def base, do: %Config.Base{id: "Mock ID", api_key: "Who Cares?"}
  def name, do: System.get_env("TABLE_NAME")
  def retrieve(_id), do: record()
  def list(_opts), do: %Airtable.List{records: [record()]}
  defp record, do: %Airtable.Record{id: "1", createdTime: "Today"}
end

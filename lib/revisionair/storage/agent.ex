defmodule Revisionair.Storage.Agent do
  @moduledoc """
  A simple implementation of the Revisionair.Storage protocol
  that builds on the Agent module.

  This is thus a very ephemeral persistence layer, which, though
  paradoxical and maybe not very practical in real-life applications,
  is at least very useful as a simple example and for testing.
  """
  @behaviour Revisionair.Storage

  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def store_revision(structure, item_type, item_id, metadata, _opts) do
    Agent.update(__MODULE__, fn item_types ->
      item_types = Map.put_new(item_types, item_type, %{})
      item_types = put_in item_types[item_type], Map.put_new(item_types[item_type], item_id, %{num_revisions: 0, revisions: %{}})

      num_revisions = item_types[item_type][item_id].num_revisions
      revisions = item_types[item_type][item_id].revisions

      put_in item_types[item_type][item_id], %{revisions: Map.put_new(revisions, num_revisions, {structure, metadata}), num_revisions: num_revisions + 1}
    end)
  end

  def list_revisions(item_type, item_id, _opts) do
    Agent.get(__MODULE__, fn
      %{^item_type => %{^item_id => %{revisions: revisions}}} ->
        revisions
        |> Enum.sort_by(fn {revision, _elem} -> -revision end)
        |> Enum.map(fn {revision, {structure, metadata}} -> {structure, Map.put(metadata, :revision, revision) }end)
      _ -> []
    end)
  end

  def newest_revision(item_type, item_id, _opts) do
    Agent.get(__MODULE__, fn
      %{^item_type => %{^item_id => %{num_revisions: num_revisions, revisions: revisions}}} ->
        case num_revisions do
          0 -> :error
          _ ->
            # revision = revisions[num_revisions - 1]
            # revision = put_in revision.metadata, :revision, num_revisions - 1

            revision = put_revision_in_metadata(revisions[num_revisions - 1], num_revisions - 1)
          {:ok, revision}
        end
      _ -> :error
    end)
  end

  def get_revision(item_type, item_id, revision, _opts) do
    IO.inspect({item_type, item_id, revision})
    Agent.get(__MODULE__, fn
      %{^item_type => %{^item_id => %{revisions: %{^revision => data}}}} ->
        {:ok, put_revision_in_metadata(data, revision)}
      _ -> :error
    end)
  end

  def delete_all_revisions_of(item_type, item_id, _opts) do
    Agent.update(__MODULE__, fn item_types ->
      pop_in item_types, [item_type, item_id]
    end)
    :ok
  end

  defp put_revision_in_metadata({data, metadata}, revision) do
    {data, Map.put(metadata, :revision, revision)}
  end
end

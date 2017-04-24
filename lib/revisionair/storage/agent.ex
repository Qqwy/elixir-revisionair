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

  def store_revision(structure, structure_type, unique_identifier, metadata, _opts) do
    Agent.update(__MODULE__, fn structure_types ->
      structure_types = Map.put_new(structure_types, structure_type, %{})
      structure_types = put_in structure_types[structure_type], Map.put_new(structure_types[structure_type], unique_identifier, %{num_revisions: 0, revisions: %{}})

      num_revisions = structure_types[structure_type][unique_identifier].num_revisions
      revisions = structure_types[structure_type][unique_identifier].revisions

      put_in structure_types[structure_type][unique_identifier], %{revisions: Map.put_new(revisions, num_revisions, {structure, metadata}), num_revisions: num_revisions + 1}
    end)
  end

  def list_revisions(structure_type, unique_identifier, _opts) do
    Agent.get(__MODULE__, fn
      %{^structure_type => %{^unique_identifier => %{revisions: revisions}}} ->
        revisions
        |> Enum.sort_by(fn {revision, _elem} -> -revision end)
        |> Enum.map(fn {revision, {structure, metadata}} -> {structure, Map.put(metadata, :revision, revision) }end)
      _ -> []
    end)
  end

  def newest_revision(structure_type, unique_identifier, _opts) do
    Agent.get(__MODULE__, fn
      %{^structure_type => %{^unique_identifier => %{num_revisions: num_revisions, revisions: revisions}}} ->
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

  def get_revision(structure_type, unique_identifier, revision, _opts) do
    IO.inspect({structure_type, unique_identifier, revision})
    Agent.get(__MODULE__, fn
      %{^structure_type => %{^unique_identifier => %{revisions: %{^revision => data}}}} ->
        {:ok, put_revision_in_metadata(data, revision)}
      _ -> :error
    end)
  end

  def delete_all_revisions_of(structure_type, unique_identifier, _opts) do
    Agent.update(__MODULE__, fn structure_types ->
      pop_in structure_types, [structure_type, unique_identifier]
    end)
  end

  defp put_revision_in_metadata({data, metadata}, revision) do
    {data, Map.put(metadata, :revision, revision)}
  end
end

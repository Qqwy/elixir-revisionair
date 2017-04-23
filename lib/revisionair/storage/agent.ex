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

  def store_revision(structure, structure_type, unique_identifier, metadata) do
    Agent.update(__MODULE__, fn structure_types ->
      structure_types = Map.put_new(structure_types, structure_type, %{})
      structure_types = put_in structure_types[structure_type], Map.put_new(structure_types[structure_type], unique_identifier, [])
      put_in structure_types[structure_type][unique_identifier], [{structure, metadata} | structure_types[structure_type][unique_identifier] || []]
    end)
  end

  def list_revisions(structure_type, unique_identifier) do
    Agent.get(__MODULE__, fn
      %{^structure_type => %{^unique_identifier => revisions}} -> revisions
      _ -> []
    end)
  end

  def newest_revision(structure_type, unique_identifier) do
    Agent.get(__MODULE__, fn
      %{^structure_type => %{^unique_identifier => [newest_revision| _]}} -> {:ok, newest_revision}
      _ -> :error
    end)
  end

  def delete_all_revisions_of(structure_type, unique_identifier) do
    Agent.update(__MODULE__, fn structure_types ->
      pop_in structure_types, [structure_type, unique_identifier]
    end)
  end
end

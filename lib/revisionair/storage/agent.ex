defmodule Revisionair.Storage.Agent do
  @behaviour Revisionair.Storage

  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end
  
  def store_revision(structure, structure_type, unique_identifier, metadata) do
    Agent.update(__MODULE__, fn structure_types ->
      structure_types = Map.put_new(structure_types, structure_type, %{})
      put_in structure_types[structure_type], Map.put_new(structure_types[structure_type], unique_identifier, [])
      put_in structure_types[structure_type][unique_identifier], [{structure, metadata} | structure_types[structure_type][unique_identifier] || []]
    end)
  end

  def list_revisions(structure_type, unique_identifier) do
    Agent.get(__MODULE__, fn structure_types ->
      get_in(structure_types, [structure_type, unique_identifier]) || []
    end)
  end

  def delete_all_revisions_of(structure_type, unique_identifier) do
    Agent.update(__MODULE__, fn structure_types ->
      pop_in structure_types, [structure_type, unique_identifier]
    end)
  end
end

defmodule Revisionair.Storage do
  @moduledoc """
  The Revisionair.Storage behaviour can be implemented
  by any persistence layer. It is used to:

  - Store the current version of a struct before it is updated.
  - Retrieve a previous version of a struct with a certain identifier.
  - List the whole history of a certain struct.

  Because Revisionair.Storage is a behaviour, you are not limited in any way
  by the kind of persistence layer you want to use.
  """

  @doc """
  Stores a new revision for the given map, uniquely identified by the {structure_type, unique_identifier} combination.
  """
  @callback store_revision(structure = %{}, structure_type = any, unique_identifier = any, metadata = %{}) :: :ok | :error

  @doc """
  Returns a {structure, metadata}-list of all revisions of the given struture, newest-to-oldest.
  """
  @callback list_revisions(structure_type, unique_identifier) :: [{structure = %{}, metadata = any}]

  @doc """
  Deletes all revisions for the given {structure_type, unique_identifier}
  """
  @callback delete_all_revisions_of(structure_type, unique_identifier) :: :ok | :error
end

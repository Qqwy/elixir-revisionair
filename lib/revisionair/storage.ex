defmodule Revisionair.Storage do
  @moduledoc """
  The Revisionair.Storage behaviour can be implemented
  by any persistence layer. It is used to:

  - Store the current version of a struct before it is updated.
  - Retrieve a previous version of a struct with a certain identifier.
  - List the whole history of a certain struct.

  Because Revisionair.Storage is a behaviour, you are not limited in any way
  by the kind of persistence layer you want to use.

  Note that, while written out in this behaviour, some Storage implementations might put
  restrictions on the kind of values `structure_type` and/or `unique_identifier` might have.
  """

  @type metadata :: %{}
  @type structure :: %{}
  @type structure_type :: integer | bitstring | atom
  @type unique_identifier :: integer | bitstring | atom

  @doc """
  Stores a new revision for the given map, uniquely identified by the {structure_type, unique_identifier} combination.
  """
  @callback store_revision(structure, structure_type, unique_identifier, metadata) :: :ok | :error

  @doc """
  Returns a {structure, metadata}-list of all revisions of the given struture, newest-to-oldest.
  """
  @callback list_revisions(structure_type, unique_identifier) :: [{structure, metadata}]

  @doc """
  Returns the newest revision for the given {structure_type, unique_identifier} combination.

  This callback is supplied decoupled from `list_revisions` for efficiency,
  because it is very common to check only the newest revision.
  """
  @callback newest_revision(structure_type, unique_identifier) :: {:ok, {structure, metadata}} | :error

  @doc """
  Deletes all revisions for the given {structure_type, unique_identifier}
  """
  @callback delete_all_revisions_of(structure_type, unique_identifier) :: :ok | :error

  @optional_callbacks newest_revision: 2
end

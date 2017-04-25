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
  restrictions on the kind of values `item_type` and/or `item_id` might have.

  ## Metadata

  A persistence layer is allowed to add more keys to the metadata map that was sent in.

  At least, the `:revision` key _must_ be set, as this can be used later to uniquely identify a single revision
  of a certain data structure, which is used in `get_revision/3`.


  ## Options

  It is possible to receive additional options; this will be the list of fields passed in from the `storage_options:` field
  of the Revisionair functions.

  If you require default values for these options, add a configuration for your specific adapter implementation.
  This means that the configuration of different storage adapters will not interfere with one another.

  """

  @type metadata :: %{revision: any}
  @type revision :: any
  @type structure :: %{}
  @type item_type :: integer | bitstring | atom
  @type item_id :: integer | bitstring | atom
  @type options :: list

  @doc """
  Stores a new revision for the given map, uniquely identified by the {item_type, item_id} combination.
  """
  @callback store_revision(structure, item_type, item_id, metadata, options) :: :ok | :error

  @doc """
  Returns a {structure, metadata}-list of all revisions of the given struture, newest-to-oldest.

  The metadata field is required to be a map, which has to include a `:revision` field.
  """
  @callback list_revisions(item_type, item_id, options) :: [{structure, metadata}]

  @doc """
  Returns the newest revision for the given {item_type, item_id} combination.

  This callback is supplied decoupled from `list_revisions` for efficiency,
  because it is very common to check only the newest revision.
  """
  @callback newest_revision(item_type, item_id, options) :: {:ok, {structure, metadata}} | :error

  @callback get_revision(item_type, item_id, revision, options) :: {:ok, {structure, metadata}} | :error

  @doc """
  Deletes all revisions for the given {item_type, item_id}
  """
  @callback delete_all_revisions_of(item_type, item_id, options) :: :ok | :error
end

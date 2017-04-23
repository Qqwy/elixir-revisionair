defmodule Revisionair do
  @moduledoc """

  Revisionair allows you to store revisions of your data structures.

  ## Persistence

  Any persistence layer can be used, as long as there exists a module implementing the Revisionair.Storage behaviour.

  Many of the functions in this module accept a `persistence: modulename` field as optional `options` argument,
  but if this is not provided, the value of `config :revisionair, :persistence` is used instead.

  ## Accepted options

  For now, only `:persistence` is an accepted option. It allows overriding the `config :revisionair, persistence` setting per function call.

  ## Metadata

  You might want to store metadata alongside with the revision you are storing.
  Some common examples include:

  - An identifier of the entity that made the revision.
  - The current datetime at which the revision occured.
  - The kind of revision that was being done.
  """

  @doc """
  Shorthand version of `store_revision/5` that assumes
  that the structure's type will be read from the `__struct__` field (the Struct's name)
  and the structure can be uniquely identified using the `id` field.
  """
  # def store_revision(structure, metadata \\ %{}, options \\ [])

  def store_revision(structure), do: store_revision(structure, %{}, [])
  def store_revision(structure, metadata) when is_map(metadata), do: store_revision(structure, metadata, [])
  def store_revision(structure, options) when is_list(options), do: store_revision(structure, %{}, options)
  def store_revision(structure, metadata, options) when is_map(metadata) and is_list(options) do
    store_revision(structure, &(&1.__struct__), &(&1.id), metadata, options)
  end

  @doc """
  Store a revision of the given structure,
  of the 'type' `structure_type`,
  uniquely identified by `unique_identifier`, with the given `metadata` and possible `options`
  in the persistence layer.

  If `structure_type` or `unique_identifier` is an arity-1 function,
  then to find the structure_type or unique_identifier, they are called on the given structure.
  As an example, the default function that extracts the unique identifier from the `:id` field of the structure, is `&(&1.id)`.
  """
  @spec store_revision(%{}, any, any, %{}, Keyword.t) :: :ok | :error
  # def store_revision(structure, structure_type, unique_identifier, metadata \\ [], options \\ [])
  def store_revision(structure, structure_type, unique_identifier), do: store_revision(structure, structure_type, unique_identifier, %{}, [])
  def store_revision(structure, structure_type, unique_identifier, metadata) when is_map(metadata) do
    store_revision(structure, structure_type, unique_identifier, metadata, [])
  end
  def store_revision(structure, structure_type, unique_identifier, options) when is_list(options) do
    store_revision(structure, structure_type, unique_identifier, %{}, options)
  end
  def store_revision(structure, structure_type, unique_identifier, metadata, options) when is_map(structure) and is_map(metadata) and is_list(options) do
    persistence_module = persistence_module(options)
    structure_type = extract_structure_type(structure, structure_type)
    unique_identifier = extract_unique_identifier(structure, unique_identifier)

    persistence_module.store_revision(structure, structure_type, unique_identifier, metadata)
  end

  @doc """
  Lists revisions for given structure,
  assuming that the structure type can be found under the structures `__struct__` key and it is uniquely identified by the `id` key.
  """
  def list_revisions(structure), do: list_revisions(structure, [])
  def list_revisions(structure, options) when is_list(options) do
    list_revisions(structure, &(&1.__struct__), &(&1.id), options)
  end

  @doc """
  Returns a list with all revisions of the structure of given type and identifier.
  """
  def list_revisions(structure_type, unique_identifier), do: list_revisions(structure_type, unique_identifier, [])
  def list_revisions(structure_type, unique_identifier, options) when is_list(options) do
    persistence_module = persistence_module(options)
    persistence_module.list_revisions(structure_type, unique_identifier)
  end

  @doc """
  A four-arity version that allows you to specify functions to call on the given structure to extract the structure_type and unique_identifier.
  Might be useful in pipelines.
  """
  def list_revisions(structure, structure_type, unique_identifier) do
    list_revisions(structure, structure_type, unique_identifier, [])
  end
  def list_revisions(structure, structure_type, unique_identifier, options) when is_function(structure_type) or is_function(unique_identifier) do
    structure_type = extract_structure_type(structure, structure_type)
    unique_identifier = extract_unique_identifier(structure, unique_identifier)

    list_revisions(structure_type, unique_identifier, options)
  end

  @doc """
  Deletes all stored revisions of the given structure.
  """
  def delete_all_revisions_of(structure), do: delete_all_revisions_of(structure, [])
  def delete_all_revisions_of(structure, options) when is_list(options) do
    delete_all_revisions_of(structure, &(&1.__struct__), &(&1.id), options)
  end

  def delete_all_revisions_of(structure_type, unique_identifier), do: delete_all_revisions_of(structure_type, unique_identifier, [])
  def delete_all_revisions_of(structure_type, unique_identifier, options) when is_list(options) do
    persistence_module = persistence_module(options)
    persistence_module.delete_all_revisions_of(structure_type, unique_identifier)
  end

  def delete_all_revisions_of(structure, structure_type, unique_identifier) do
    delete_all_revisions_of(structure, structure_type, unique_identifier, [])
  end
  def delete_all_revisions_of(structure, structure_type, unique_identifier, options) when is_list(options) do
    structure_type = extract_structure_type(structure, structure_type)
    unique_identifier = extract_unique_identifier(structure, unique_identifier)

    delete_all_revisions_of(structure_type, unique_identifier, options)
  end

  defp persistence_module(options) do
    options[:persistence] || Application.fetch_env!(:revisionair, :persistence)
  end

  defp extract_structure_type(structure, structure_type) when is_function(structure_type, 1) do
    structure_type.(structure)
  end
  defp extract_structure_type(_structure, structure_type), do: structure_type

  defp extract_unique_identifier(structure, unique_identifier) when is_function(unique_identifier, 1) do
    unique_identifier.(structure)
  end
  defp extract_unique_identifier(_structure, unique_identifier), do: unique_identifier
end

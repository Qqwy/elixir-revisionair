defmodule Revisionair do
  @moduledoc """

  Revisionair allows you to store revisions of your data structures.

  ## Storage

  Any storage layer can be used, as long as there exists a module implementing the Revisionair.Storage behaviour.

  Many of the functions in this module accept a `storage: modulename` field as optional `options` argument,
  but if this is not provided, the value of `config :revisionair, :storage` is used instead.

  ## Accepted options

  - `:storage`: Allows overriding the `config :revisionair, storage` setting per function call. This should be set to the module implementing the Revisionair.Storage behaviour that you want to use.
  - `:storage_options`: The list passed to this will be passed through to the used storage adapter. This can be used to have per-function-call different settings for the storage adapter.

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

      iex> Revisionair.Storage.Agent.start_link
      iex> Revisionair.store_revision(%{id: 1, foo: 2, __struct__: Car}, [storage: Revisionair.Storage.Agent])
      :ok
      iex> my_car = %{wheels: 4, color: "black"}
      iex> Revisionair.store_revision(my_car, Vehicle, 1, [metadata: %{editor_id: 1}, storage: Revisionair.Storage.Agent])
      :ok
  """
  def store_revision(structure), do: store_revision(structure, %{}, [])
  # def store_revision(structure, metadata) when is_map(metadata), do: store_revision(structure, metadata, [])
  def store_revision(structure, options) when is_list(options) do
    store_revision(structure, &(&1.__struct__), &(&1.id), options)
  end

  @doc """
  Store a revision of the given structure,
  of the 'type' `item_type`,
  uniquely identified by `item_id`, and possibly with the given `options`
  in the storage layer.

  If `item_type` or `item_id` is an arity-1 function,
  then to find the item_type or item_id, they are called on the given structure.
  As an example, the default function that extracts the unique identifier from the `:id` field of the structure, is `&(&1.id)`.

  `options` might contain the `metadata:` field, in which case the given metadata is saved alongside the stored structure.
  """
  def store_revision(structure, item_type, item_id), do: store_revision(structure, item_type, item_id, [])
  def store_revision(structure, item_type, item_id, options) when is_map(structure) and is_list(options) do
    storage_module = storage_module(options)
    storage_options = extract_storage_options(options)
    item_type = extract_item_type(structure, item_type)
    item_id = extract_item_id(structure, item_id)
    metadata = Keyword.get(options, :metadata, %{})

    storage_module.store_revision(structure, item_type, item_id, metadata, storage_options)
  end

  @doc """
  Lists revisions for given structure,
  assuming that the structure type can be found under the structures `__struct__` key and it is uniquely identified by the `id` key.


      iex> Revisionair.Storage.Agent.start_link
      iex> my_car = %{wheels: 4, color: "black"}
      iex> Revisionair.store_revision(my_car, Vehicle, 1, [metadata: %{editor_id: 1}, storage: Revisionair.Storage.Agent])
      iex> my_car = %{my_car | color: "green"}
      iex> Revisionair.store_revision(my_car, Vehicle, 1, [metadata: %{editor_id: 1}, storage: Revisionair.Storage.Agent])
      iex> Revisionair.list_revisions(Vehicle, 1, [storage: Revisionair.Storage.Agent])
      [{%{color: "green", wheels: 4}, %{editor_id: 1, revision: 1}},
      {%{color: "black", wheels: 4}, %{editor_id: 1, revision: 0}}]
  """
  def list_revisions(structure), do: list_revisions(structure, [])
  def list_revisions(structure, options) when is_list(options) do
    list_revisions(structure, &(&1.__struct__), &(&1.id), options)
  end

  @doc """
  Returns a list with all revisions of the structure of given type and identifier.
  """
  def list_revisions(item_type, item_id), do: list_revisions(item_type, item_id, [])
  def list_revisions(item_type, item_id, options) when is_list(options) do
    storage_module = storage_module(options)
    storage_options = extract_storage_options(options)
    storage_module.list_revisions(item_type, item_id, storage_options)
  end

  @doc """
  A four-arity version that allows you to specify functions to call on the given structure to extract the item_type and item_id.
  Used internally; part of the public API as it might be useful in pipelines.
  """
  def list_revisions(structure, item_type, item_id) do
    list_revisions(structure, item_type, item_id, [])
  end
  def list_revisions(structure, item_type, item_id, options) when is_function(item_type) or is_function(item_id) do
    item_type = extract_item_type(structure, item_type)
    item_id = extract_item_id(structure, item_id)

    list_revisions(item_type, item_id, options)
  end

  @doc """
  Returns the newest stored revision for the given structure,
  assuming that the structure type can be found under the structures `__struct__` key and it is uniquely identified by the `id` key.
  """
  def newest_revision(structure), do: newest_revision(structure, [])
  def newest_revision(structure, options) when is_list(options) do
    newest_revision(structure, &(&1.__struct__), &(&1.id), options)
  end

  @doc """
  Returns the newest stored revision of the structure of given type and identifier.
  """
  def newest_revision(item_type, item_id), do: newest_revision(item_type, item_id, [])
  def newest_revision(item_type, item_id, options) when is_list(options) do
    storage_module = storage_module(options)
    storage_options = extract_storage_options(options)
    storage_module.newest_revision(item_type, item_id, storage_options)
  end

  @doc """
  A four-arity version that allows you to specify functions to call on the given structure to extract the item_type and item_id.
  Used internally; part of the public API as it might be useful in pipelines.
  """
  def newest_revision(structure, item_type, item_id) do
    newest_revision(structure, item_type, item_id, [])
  end
  def newest_revision(structure, item_type, item_id, options) when is_function(item_type) or is_function(item_id) do
    item_type = extract_item_type(structure, item_type)
    item_id = extract_item_id(structure, item_id)

    newest_revision(item_type, item_id, options)
  end

  @doc """
  Returns the stored revision for the given structure, with the given `revision`.
  assuming that the structure type can be found under the structures `__struct__` key and it is uniquely identified by the `id` key.
  """
  def get_revision(structure, revision) do
    get_revision(structure, revision, [])
  end
  def get_revision(structure, revision, options) when is_list(options) do
    get_revision(structure, &(&1.__struct__), &(&1.id), revision, options)
  end

  @doc """
  Returns the newest stored revision of the structure of given type and identifier.
  """
  def get_revision(item_type, item_id, revision), do: get_revision(item_type, item_id, revision, [])
  def get_revision(item_type, item_id, revision, options) when is_list(options) do
    storage_module = storage_module(options)
    storage_options = extract_storage_options(options)
    storage_module.get_revision(item_type, item_id, revision, storage_options)
  end

  def get_revision(structure, item_type, item_id, revision) do
    get_revision(structure, item_type, item_id, revision, [])
  end
  def get_revision(structure, item_type, item_id, revision, options) when is_list(options) do
    item_type = extract_item_type(structure, item_type)
    item_id = extract_item_id(structure, item_id)

    get_revision(item_type, item_id, revision, options)
  end

  @doc """
  Deletes all stored revisions of the given structure.
  """
  def delete_all_revisions_of(structure), do: delete_all_revisions_of(structure, [])
  def delete_all_revisions_of(structure, options) when is_list(options) do
    delete_all_revisions_of(structure, &(&1.__struct__), &(&1.id), options)
  end

  def delete_all_revisions_of(item_type, item_id), do: delete_all_revisions_of(item_type, item_id, [])
  def delete_all_revisions_of(item_type, item_id, options) when is_list(options) do
    storage_module = storage_module(options)
    storage_options = extract_storage_options(options)
    storage_module.delete_all_revisions_of(item_type, item_id, storage_options)
  end

  def delete_all_revisions_of(structure, item_type, item_id) do
    delete_all_revisions_of(structure, item_type, item_id, [])
  end
  def delete_all_revisions_of(structure, item_type, item_id, options) when is_list(options) do
    item_type = extract_item_type(structure, item_type)
    item_id = extract_item_id(structure, item_id)

    delete_all_revisions_of(item_type, item_id, options)
  end

  # Either read from the options, or otherwise from the application configuration.
  defp storage_module(options) do
    options[:storage] || Application.fetch_env!(:revisionair, :storage)
  end

  defp extract_item_type(structure, item_type) when is_function(item_type, 1) do
    item_type.(structure)
  end
  defp extract_item_type(_structure, item_type), do: item_type

  defp extract_item_id(structure, item_id) when is_function(item_id, 1) do
    item_id.(structure)
  end
  defp extract_item_id(_structure, item_id), do: item_id

  defp extract_storage_options(options), do: options[:storage_options] || []
end

# Revisionair

Revisionair is a small Elixir library that allows you to create revisions, or versioning, of your data structures.
Each time a data structure is updated, you can store the new version. Revisionair will keep track of the versions you have stored.

Revisionair is completely persistence-layer agnostic, meaning that regardless of if you use Ecto, Mnesia, Flat files, a simple ephemeral Agent,
or a complex sharded database setup with your toaster as extra redundancy,
you can use it with Revisionair, by simply implementing the `Revisionair.Storage` behaviour.


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `revisionair` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:revisionair, "~> 0.9.0"}]
end
```


## Super Simple Usage

1. Whenever a data structure you care about changes, besides storing this latest revision at its primary location,
you also store it using Revisionair, using `Revisionair.store_revision(my_data_structure)`.
2. If you find out you liked an old version better, you can find it again by using `Revisionair.list_revisions(my_current_data_structure)`

## Configurable

The lower-arity versions of Revisionair expect that you use structs that contain an `:id` field: The `:__struct__` key 
is used to differentiate between different kinds of data (i.e. data types) that are stored, while the `:id` field is used
to differentiate between different entities of this data type.

However, this is fully configurable. Revisionair's functions can be called with custom `structure_type`s and `unique_identifier` fields,
and when you pass (arity-1) functions as these arguments, they are called on the passed structure. So this also works:

```elixir
%Car{uuid: "14dac99c-5dde-4301-846b-3d1fa21171cc", color: "black", number_of_wheels: 4}
|> Revisionair.store_revision(Vehicle, &(&1.uuid))
```

which might both be useful if you do not use an `:id` field, or if you have structs whose 
`__struct__` type might change.


## Storage

The persistence layer that Revisionair uses is fully configurable.

Which Revisionair.Storage implementation you use can be configured app-wide using the
`config :revisionair, persistence: Module.That.Implements.Revisionair.Storage` configuration setting.

When you want to override this setting, or have more complicated persistence needs (multiple different kinds of persistence in the same application?),
you can pass `persistence: Module.That.Implements.Revisionair.Storage` as option to all functions in the `Revolutionair` module:

```elixir
Revisionair.store_revision(my_structure, [persistence: Revisionair.Storage.Agent])
# or:
Revisionair.store_revision(my_car, Vehicle, my_car.id, [persistence: Revisionair.Storage.Agent])
# or:
Revisionair.store_revision(my_car, Vehicle, my_car.id, %{editor: current_user}, [persistence: Revisionair.Storage.Agent])
```

Revisionair ships with a very simple `Agent` layer that is used for testing.

For your practical applications, some other versions might be more appropriate.

Other packages might be made by me or other people, that combine Revisionair with any of the
databases and other persistence layers out there. They will be listed here.

Of course, writing your own `Revisionair.Storage` implementation is very simple, as the behaviour only requires you to implement three functions.


## Metadata

If you want to store extra data, such as the time at which the revision took place, or who made the new revision,
you can do so by using the `metadata` argument when using `store_revision`. 

This metadata is returned when `list_revisions` or `newest_revision` is called at a later time.

What information you store in here is completely up to you (but it is expected to be a map).


Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/revisionair](https://hexdocs.pm/revisionair).


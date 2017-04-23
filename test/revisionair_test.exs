defmodule RevisionairTest do
  use ExUnit.Case
  doctest Revisionair

  defmodule TestStruct do
    defstruct id: 0, foo: 1, bar: 2
  end


  test "Simple flow using test Revision.Storage.Agent" do
    Revisionair.Storage.Agent.start_link
    f1 = %TestStruct{id: 1, foo: 0}
    f1b = %TestStruct{f1 | foo: 2, bar: 3}

    assert Revisionair.store_revision(f1, [persistence: Revisionair.Storage.Agent]) == :ok
    assert Revisionair.store_revision(f1b, [persistence: Revisionair.Storage.Agent]) == :ok
    assert Revisionair.list_revisions(f1b, [persistence: Revisionair.Storage.Agent]) == [{f1b, %{}},
                                                                                          {f1, %{}}]
    assert Revisionair.delete_all_revisions_of(f1b, [persistence: Revisionair.Storage.Agent]) == :ok
    assert Revisionair.list_revisions(f1b, [persistence: Revisionair.Storage.Agent]) == []
    assert Revisionair.list_revisions(f1, [persistence: Revisionair.Storage.Agent]) == []
  end

  test "explicit structure_type and unique_identifier with Revision.Storage.Agent" do
    Revisionair.Storage.Agent.start_link
    f1 = %TestStruct{id: 1, foo: 0}
    f1b = %TestStruct{f1 | foo: 2, bar: 3}

    assert Revisionair.store_revision(f1, TestStruct, 1, [persistence: Revisionair.Storage.Agent]) == :ok
    assert Revisionair.store_revision(f1b, [persistence: Revisionair.Storage.Agent]) == :ok
    assert Revisionair.list_revisions(TestStruct, 1, [persistence: Revisionair.Storage.Agent]) == [{f1b, %{}},
                                                                                                   {f1, %{}}]
  end
end


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
    assert Revisionair.list_revisions(f1b, [persistence: Revisionair.Storage.Agent]) == [{f1b, %{revision: 1}},
                                                                                          {f1, %{revision: 0}}]
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
    assert Revisionair.list_revisions(TestStruct, 1, [persistence: Revisionair.Storage.Agent]) == [{f1b, %{revision: 1}},
                                                                                                   {f1, %{revision: 0}}]
  end

  test "get_revision" do
    Revisionair.Storage.Agent.start_link
    f1 = %TestStruct{id: 1, foo: 0}
    f1b = %TestStruct{f1 | foo: 2, bar: 3}

    Revisionair.store_revision(f1, [persistence: Revisionair.Storage.Agent])
    Revisionair.store_revision(f1b, [persistence: Revisionair.Storage.Agent])

    assert Revisionair.get_revision(f1b, 1, [persistence: Revisionair.Storage.Agent]) == \
    {:ok, {%RevisionairTest.TestStruct{bar: 3, foo: 2, id: 1}, %{revision: 1}}}
    assert Revisionair.get_revision(f1b, 0, [persistence: Revisionair.Storage.Agent]) == \
    {:ok, {%RevisionairTest.TestStruct{bar: 2, foo: 0, id: 1}, %{revision: 0}}}

  end
end

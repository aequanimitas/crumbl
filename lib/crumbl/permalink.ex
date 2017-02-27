defmodule Crumbl.Permalink do
  @moduledoc """
  Associate slug url behavior with id fields
  """
  @behaviour Ecto.Type
  
  def type, do: :id

  # called when external data is passed to Ecto
  # pattern-match while being lenient and careful
  def cast(binary) when is_binary(binary) do
    case Integer.parse(binary) do
      {int, _} when int > 0 -> {:ok, int}
      _ -> :error
    end
  end

  # called when external data is passed to Ecto
  def cast(integer) when is_integer(integer) do
    {:ok, integer}
  end

  # called when external data is passed to Ecto
  def cast(_) do
    :error
  end

  # called when data is sent to db
  def dump(integer) when is_integer(integer) do
    {:ok, integer}
  end

  # called when data is loaded from db
  def load(integer) when is_integer(integer) do
    {:ok, integer}
  end
end

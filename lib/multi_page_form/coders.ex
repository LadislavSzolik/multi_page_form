defmodule MultiPageForm.Coders do
  @moduledoc """
  The Coders context.
  """

  import Ecto.Query, warn: false
  alias MultiPageForm.Repo

  alias MultiPageForm.Coders.Coder

  @doc """
  Returns the list of coders.

  ## Examples

      iex> list_coders()
      [%Coder{}, ...]

  """
  def list_coders do
    Repo.all(Coder)
  end

  @doc """
  Gets a single coder.

  Raises `Ecto.NoResultsError` if the Coder does not exist.

  ## Examples

      iex> get_coder!(123)
      %Coder{}

      iex> get_coder!(456)
      ** (Ecto.NoResultsError)

  """
  def get_coder!(id), do: Repo.get!(Coder, id)

  @doc """
  Creates a coder.

  ## Examples

      iex> create_coder(%{field: value})
      {:ok, %Coder{}}

      iex> create_coder(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_coder(%Coder{} = coder, attrs \\ %{}) do
    coder
    |> Coder.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a coder.

  ## Examples

      iex> update_coder(coder, %{field: new_value})
      {:ok, %Coder{}}

      iex> update_coder(coder, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_coder(%Coder{} = coder, attrs) do
    coder
    |> Coder.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a coder.

  ## Examples

      iex> delete_coder(coder)
      {:ok, %Coder{}}

      iex> delete_coder(coder)
      {:error, %Ecto.Changeset{}}

  """
  def delete_coder(%Coder{} = coder) do
    Repo.delete(coder)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking coder changes.

  ## Examples

      iex> change_coder(coder)
      %Ecto.Changeset{data: %Coder{}}

  """
  def change_coder(%Coder{} = coder, attrs \\ %{}) do
    Coder.changeset(coder, attrs)
  end
end

defmodule QuizApp.Quiz.Question do
  use Ecto.Schema
  import Ecto.Changeset

  schema "questions" do
    field :question, :string
    field :options, {:array, :string}
    field :correct_answer, :string
    field :motivation, :string

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(question, attrs) do
    question
    |> cast(attrs, [:question, :options, :correct_answer, :motivation])
    |> validate_required([:question, :options, :correct_answer, :motivation])
    |> validate_options_count()
    |> validate_correct_answer_in_options()
  end

  defp validate_options_count(changeset) do
    case get_field(changeset, :options) do
      nil ->
        add_error(changeset, :options, "must be present")

      options when is_list(options) ->
        if length(options) == 4 do
          changeset
        else
          add_error(changeset, :options, "must contain exactly 4 options")
        end

      _ ->
        add_error(changeset, :options, "must be a list of strings")
    end
  end

  defp validate_correct_answer_in_options(changeset) do
    case {get_field(changeset, :correct_answer), get_field(changeset, :options)} do
      {nil, _} ->
        changeset

      {_, nil} ->
        changeset

      {correct_answer, options} when is_list(options) ->
        if Enum.member?(options, correct_answer) do
          changeset
        else
          add_error(changeset, :correct_answer, "must be one of the options")
        end

      _ ->
        changeset
    end
  end
end

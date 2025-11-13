defmodule QuizApp.Quiz do
  import Ecto.Query
  alias QuizApp.Repo
  alias QuizApp.Quiz.Question

  @doc """
  Get N random unique questions from the database.

  Uses RANDOM() for randomization and LIMIT to get exactly N questions.
  """
  def get_random_questions(count \\ 10) do
    Question
    |> order_by(fragment("RANDOM()"))
    |> limit(^count)
    |> Repo.all()
  end

  @doc """
  Get all questions from the database.

  Useful for seeding verification and admin purposes.
  """
  def get_all_questions do
    Repo.all(Question)
  end

  @doc """
  Get total count of questions in the database.
  """
  def get_question_count do
    Repo.aggregate(Question, :count)
  end

  @doc """
  Create a new question.

  Used during seeding.
  """
  def create_question(attrs \\ {}) do
    %Question{}
    |> Question.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Delete all questions from the database.

  Useful for reseeding.
  """
  def delete_all_questions do
    Repo.delete_all(Question)
  end
end

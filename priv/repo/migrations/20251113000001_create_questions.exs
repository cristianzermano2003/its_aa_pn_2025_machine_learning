defmodule QuizApp.Repo.Migrations.CreateQuestions do
  use Ecto.Migration

  def change do
    create table(:questions) do
      add :question, :string, null: false
      add :options, {:array, :string}, null: false
      add :correct_answer, :string, null: false
      add :motivation, :text, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create index(:questions, [:inserted_at])
  end
end

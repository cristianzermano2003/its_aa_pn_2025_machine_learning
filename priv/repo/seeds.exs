import Ecto.Query

alias QuizApp.Repo
alias QuizApp.Quiz.Question

# Load and parse seeding.json
seed_file = Path.join(:code.priv_dir(:quiz_app), "repo/seeding.json")

case File.read(seed_file) do
  {:ok, content} ->
    case Jason.decode(content) do
      {:ok, questions_data} ->
        # Clear existing questions
        Repo.delete_all(Question)

        # Insert all questions from seeding.json
        Enum.each(questions_data, fn question_attrs ->
          %Question{}
          |> Question.changeset(question_attrs)
          |> Repo.insert!()
        end)

        IO.puts("✓ Seeded #{length(questions_data)} questions successfully")

      {:error, decode_error} ->
        IO.puts("✗ Error decoding seeding.json: #{inspect(decode_error)}")
    end

  {:error, file_error} ->
    IO.puts("✗ Error reading seeding.json: #{inspect(file_error)}")
end

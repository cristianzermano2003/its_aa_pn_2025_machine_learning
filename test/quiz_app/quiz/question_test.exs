defmodule QuizApp.Quiz.QuestionTest do
  use QuizApp.DataCase

  alias QuizApp.Quiz.Question

  describe "changeset/2" do
    test "valid changeset with all required fields" do
      valid_attrs = %{
        question: "What is 2+2?",
        options: ["3", "4", "5", "6"],
        correct_answer: "4",
        motivation: "Because 2+2 equals 4."
      }

      changeset = Question.changeset(%Question{}, valid_attrs)
      assert changeset.valid?
    end

    test "invalid changeset missing question" do
      invalid_attrs = %{
        options: ["3", "4", "5", "6"],
        correct_answer: "4",
        motivation: "Because 2+2 equals 4."
      }

      changeset = Question.changeset(%Question{}, invalid_attrs)
      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).question
    end

    test "invalid changeset with wrong number of options" do
      invalid_attrs = %{
        question: "What is 2+2?",
        options: ["3", "4", "5"],
        correct_answer: "4",
        motivation: "Because 2+2 equals 4."
      }

      changeset = Question.changeset(%Question{}, invalid_attrs)
      refute changeset.valid?
      assert "must contain exactly 4 options" in errors_on(changeset).options
    end

    test "invalid changeset with correct_answer not in options" do
      invalid_attrs = %{
        question: "What is 2+2?",
        options: ["3", "4", "5", "6"],
        correct_answer: "7",
        motivation: "Because 2+2 equals 4."
      }

      changeset = Question.changeset(%Question{}, invalid_attrs)
      refute changeset.valid?
      assert "must be one of the options" in errors_on(changeset).correct_answer
    end

    test "valid changeset with options count exactly 4" do
      valid_attrs = %{
        question: "Multiple choice question",
        options: ["Option A", "Option B", "Option C", "Option D"],
        correct_answer: "Option B",
        motivation: "Detailed explanation here."
      }

      changeset = Question.changeset(%Question{}, valid_attrs)
      assert changeset.valid?
    end
  end

  defp errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Enum.reduce(opts, message, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end

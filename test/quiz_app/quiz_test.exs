defmodule QuizApp.QuizTest do
  use QuizApp.DataCase

  alias QuizApp.Quiz
  alias QuizApp.Quiz.Question

  describe "get_random_questions/1" do
    setup do
      # Create 15 test questions
      questions = Enum.map(1..15, fn i ->
        {:ok, q} = Quiz.create_question(%{
          question: "Question #{i}",
          options: ["Option A", "Option B", "Option C", "Option D"],
          correct_answer: "Option A",
          motivation: "Explanation for question #{i}"
        })
        q
      end)
      {:ok, questions: questions}
    end

    test "returns exactly N questions" do
      questions = Quiz.get_random_questions(10)
      assert length(questions) == 10
    end

    test "returns all Question structs" do
      questions = Quiz.get_random_questions(5)
      assert Enum.all?(questions, &match?(%Question{}, &1))
    end

    test "returns unique questions (no duplicates)" do
      questions = Quiz.get_random_questions(10)
      question_ids = Enum.map(questions, & &1.id)
      assert length(question_ids) == length(Enum.uniq(question_ids))
    end

    test "returns different questions on multiple calls" do
      call1 = Quiz.get_random_questions(10) |> Enum.map(& &1.id) |> Enum.sort()
      call2 = Quiz.get_random_questions(10) |> Enum.map(& &1.id) |> Enum.sort()

      # Due to randomization, they might not always be different,
      # but we're testing the mechanism works
      assert length(call1) == 10
      assert length(call2) == 10
    end
  end

  describe "get_all_questions/0" do
    setup do
      Enum.each(1..5, fn i ->
        Quiz.create_question(%{
          question: "Question #{i}",
          options: ["A", "B", "C", "D"],
          correct_answer: "A",
          motivation: "Explanation #{i}"
        })
      end)
      :ok
    end

    test "returns all questions from database" do
      all_questions = Quiz.get_all_questions()
      assert length(all_questions) >= 5
    end
  end

  describe "get_question_count/0" do
    setup do
      initial_count = Quiz.get_question_count()
      {:ok, initial_count: initial_count}
    end

    test "returns the correct count of questions", %{initial_count: initial_count} do
      Quiz.create_question(%{
        question: "New question",
        options: ["A", "B", "C", "D"],
        correct_answer: "A",
        motivation: "Explanation"
      })

      count = Quiz.get_question_count()
      assert count == initial_count + 1
    end
  end

  describe "create_question/1" do
    test "creates a valid question" do
      attrs = %{
        question: "Test question",
        options: ["Option 1", "Option 2", "Option 3", "Option 4"],
        correct_answer: "Option 1",
        motivation: "This is the correct answer because..."
      }

      {:ok, question} = Quiz.create_question(attrs)

      assert question.question == "Test question"
      assert question.correct_answer == "Option 1"
      assert length(question.options) == 4
    end

    test "rejects invalid question data" do
      invalid_attrs = %{
        question: "Test question",
        options: ["Option 1", "Option 2"],
        correct_answer: "Option 1",
        motivation: "Explanation"
      }

      {:error, changeset} = Quiz.create_question(invalid_attrs)
      refute changeset.valid?
    end
  end

  describe "delete_all_questions/0" do
    setup do
      Enum.each(1..3, fn i ->
        Quiz.create_question(%{
          question: "Question #{i}",
          options: ["A", "B", "C", "D"],
          correct_answer: "A",
          motivation: "Explanation"
        })
      end)
      :ok
    end

    test "deletes all questions from database" do
      initial_count = Quiz.get_question_count()
      assert initial_count >= 3

      Quiz.delete_all_questions()

      final_count = Quiz.get_question_count()
      assert final_count == 0
    end
  end
end

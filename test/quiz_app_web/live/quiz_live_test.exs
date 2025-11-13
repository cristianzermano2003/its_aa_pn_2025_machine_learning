defmodule QuizAppWeb.QuizLiveTest do
  use QuizAppWeb.ConnCase

  import Phoenix.LiveViewTest

  alias QuizApp.Quiz

  setup do
    # Create test questions
    questions = Enum.map(1..10, fn i ->
      {:ok, q} = Quiz.create_question(%{
        question: "Question #{i}?",
        options: ["Option A", "Option B", "Option C", "Option D"],
        correct_answer: "Option A",
        motivation: "Explanation for question #{i}."
      })
      q
    end)

    {:ok, questions: questions}
  end

  describe "Quiz LiveView" do
    test "renders quiz form on initial load", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/quiz")

      assert has_element?(view, "#quiz-form")
      assert has_element?(view, "button[type='submit']")
    end

    test "displays all 10 questions", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/quiz")

      # Check that all 10 questions are rendered
      for i <- 1..10 do
        assert has_element?(view, "h2", "Question #{i} of 10")
      end
    end

    test "submit button is disabled initially", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/quiz")

      assert has_element?(view, "button[disabled]", "Submit Quiz")
    end

    test "handles answer selection", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/quiz")

      # Select first question's first option
      view
      |> element("[id*='question_0_option_0']")
      |> render_click()

      assert has_element?(view, "input[checked]")
    end

    test "handles motivation input", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/quiz")

      # Fill in motivation for first question
      view
      |> form("form", %{"question_0_motivation" => "This is my answer because..."})
      |> render_change()

      # The motivation should be stored in the socket state
      assert render(view) =~ "This is my answer because..."
    end

    test "submit button is enabled when all questions are answered", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/quiz")

      # Get questions to know their IDs
      questions = Quiz.get_random_questions(10)

      # Answer all questions
      for {question, index} <- Enum.with_index(questions) do
        # Select answer
        view
        |> element("[id*='question_#{index}_option_0']")
        |> render_click()

        # Fill motivation
        view
        |> form("form", %{"question_#{index}_motivation" => "Answer for question #{index}"})
        |> render_change()
      end

      # Submit button should now be enabled
      assert has_element?(view, "button:not([disabled])", "Submit Quiz")
    end

    test "displays results view after submission", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/quiz")

      questions = Quiz.get_random_questions(10)

      # Answer all questions
      for {question, index} <- Enum.with_index(questions) do
        view
        |> element("[id*='question_#{index}_option_0']")
        |> render_click()

        view
        |> form("form", %{"question_#{index}_motivation" => "My answer"})
        |> render_change()
      end

      # Submit quiz
      view
      |> form("form")
      |> render_submit()

      # Check that results are displayed
      html = render(view)
      assert html =~ "Quiz Complete!"
      assert html =~ "/ 10"
    end

    test "shows correct/incorrect answers in results", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/quiz")

      questions = Quiz.get_random_questions(10)

      # Answer with first option for all questions
      # (we created them all with "Option A" as correct answer)
      for {question, index} <- Enum.with_index(questions) do
        view
        |> element("[id*='question_#{index}_option_0']")
        |> render_click()

        view
        |> form("form", %{"question_#{index}_motivation" => "My answer"})
        |> render_change()
      end

      view
      |> form("form")
      |> render_submit()

      html = render(view)
      # All answers should be correct (Option A is correct)
      assert html =~ "✓ Correct"
    end

    test "shows explanation for each question in results", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/quiz")

      questions = Quiz.get_random_questions(10)

      for {_question, index} <- Enum.with_index(questions) do
        view
        |> element("[id*='question_#{index}_option_0']")
        |> render_click()

        view
        |> form("form", %{"question_#{index}_motivation" => "My answer"})
        |> render_change()
      end

      view
      |> form("form")
      |> render_submit()

      html = render(view)
      assert html =~ "Explanation:"
    end

    test "retake quiz resets state", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/quiz")

      questions = Quiz.get_random_questions(10)

      for {_question, index} <- Enum.with_index(questions) do
        view
        |> element("[id*='question_#{index}_option_0']")
        |> render_click()

        view
        |> form("form", %{"question_#{index}_motivation" => "My answer"})
        |> render_change()
      end

      view
      |> form("form")
      |> render_submit()

      # Check we're in results view
      assert has_element?(view, "button", "Retake Quiz")

      # Click retake
      view
      |> element("button", "Retake Quiz")
      |> render_click()

      # Should be back to quiz form (disabled submit button means no answers yet)
      assert has_element?(view, "#quiz-form")
      assert has_element?(view, "button[disabled]", "Submit Quiz")
    end

    test "does not allow submission with empty motivation", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/quiz")

      questions = Quiz.get_random_questions(10)

      # Answer all questions but leave one motivation empty
      for {_question, index} <- Enum.with_index(questions) do
        view
        |> element("[id*='question_#{index}_option_0']")
        |> render_click()

        if index < 9 do
          view
          |> form("form", %{"question_#{index}_motivation" => "My answer"})
          |> render_change()
        end
      end

      # Submit button should still be disabled
      assert has_element?(view, "button[disabled]", "Submit Quiz")
    end
  end
end

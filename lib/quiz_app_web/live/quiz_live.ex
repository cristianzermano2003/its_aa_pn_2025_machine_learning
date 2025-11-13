defmodule QuizAppWeb.QuizLive do
  use QuizAppWeb, :live_view

  alias QuizApp.Quiz

  @impl true
  def mount(_params, _session, socket) do
    # Load 10 random unique questions
    questions = Quiz.get_random_questions(10)

    # Initialize socket assigns
    socket =
      socket
      |> assign(:page_title, "Quiz")
      |> assign(:questions, questions)
      |> assign(:user_answers, %{})
      |> assign(:user_motivations, %{})
      |> assign(:quiz_submitted, false)
      |> assign(:final_score, nil)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    if assigns.quiz_submitted do
      render_results(assigns)
    else
      render_quiz(assigns)
    end
  end

  defp render_quiz(assigns) do
    ~H"""
    <QuizAppWeb.Layouts.app flash={@flash} current_scope={nil}>
      <div class="max-w-4xl mx-auto">
        <h1 class="text-3xl font-bold text-gray-900 mb-2">Quiz</h1>
        <p class="text-gray-600 mb-6">Answer all 10 questions below. Each question requires both an answer selection and a written motivation.</p>

        <form phx-submit="submit_quiz" id="quiz-form" class="space-y-8">
          <%= for {question, index} <- Enum.with_index(@questions) do %>
            <div class="bg-white p-6 rounded-lg shadow border border-gray-200">
              <div class="mb-4">
                <h2 class="text-lg font-semibold text-gray-900">
                  Question <%= index + 1 %> of <%= length(@questions) %>
                </h2>
                <p class="text-gray-800 mt-2"><%= question.question %></p>
              </div>

              <!-- Answer Options -->
              <div class="mb-6 space-y-3">
                <div class="text-sm font-medium text-gray-700 mb-3">Select one answer:</div>
                <%= for option <- question.options do %>
                  <label class="flex items-center p-3 border border-gray-300 rounded-lg hover:bg-blue-50 cursor-pointer transition-colors" id={"question_#{index}_option_#{Enum.find_index(question.options, &(&1 == option))}"}
                    phx-click="answer_selected"
                    phx-value-question-id={question.id}
                    phx-value-answer={option}>
                    <input
                      type="radio"
                      name={"question_#{index}_answer"}
                      value={option}
                      checked={Map.get(@user_answers, question.id) == option}
                      class="rounded border-gray-300 text-blue-600 focus:ring-blue-500"
                    />
                    <span class="ml-3 text-gray-700"><%= option %></span>
                  </label>
                <% end %>
              </div>

              <!-- Motivation -->
              <div>
                <label for={"question_#{index}_motivation"} class="block text-sm font-medium text-gray-700 mb-2">
                  Your Motivation/Reasoning:
                </label>
                <textarea
                  id={"question_#{index}_motivation"}
                  name={"question_#{index}_motivation"}
                  rows="3"
                  placeholder="Explain your reasoning for the answer you selected..."
                  phx-change="motivation_changed"
                  phx-value-question-id={question.id}
                  class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 text-sm"
                ><%=
                  Map.get(@user_motivations, question.id, "")
                %></textarea>
              </div>
            </div>
          <% end %>

          <!-- Submit Button -->
          <div class="flex justify-center mt-8">
            <button
              type="submit"
              disabled={not is_quiz_complete?(@user_answers, @user_motivations, length(@questions))}
              class={[
                "px-8 py-3 rounded-lg font-semibold text-white transition-colors",
                is_quiz_complete?(@user_answers, @user_motivations, length(@questions)) and "bg-blue-600 hover:bg-blue-700",
                not is_quiz_complete?(@user_answers, @user_motivations, length(@questions)) and "bg-gray-400 cursor-not-allowed"
              ]}
            >
              Submit Quiz
            </button>
          </div>
        </form>
      </div>
    </QuizAppWeb.Layouts.app>
    """
  end

  defp render_results(assigns) do
    ~H"""
    <QuizAppWeb.Layouts.app flash={@flash} current_scope={nil}>
      <div class="max-w-4xl mx-auto">
        <!-- Score Card -->
        <div class="bg-gradient-to-r from-blue-50 to-blue-100 border border-blue-200 rounded-lg p-8 mb-8 text-center">
          <h1 class="text-4xl font-bold text-blue-900 mb-2">Quiz Complete!</h1>
          <p class="text-6xl font-bold text-blue-600 mb-2"><%= @final_score %> / <%= length(@questions) %></p>
          <p class="text-blue-800">
            You got <%= @final_score %> out of <%= length(@questions) %> questions correct.
          </p>
        </div>

        <!-- Detailed Feedback -->
        <div class="space-y-6">
          <%= for {question, index} <- Enum.with_index(@questions) do %>
            <%
              user_answer = Map.get(@user_answers, question.id)
              is_correct = user_answer == question.correct_answer
            %>
            <div class={["bg-white p-6 rounded-lg shadow border-l-4", is_correct and "border-l-green-500 bg-green-50", not is_correct and "border-l-red-500 bg-red-50"]}>
              <div class="mb-4">
                <div class="flex items-start justify-between mb-2">
                  <h2 class="text-lg font-semibold text-gray-900">
                    Question <%= index + 1 %>
                  </h2>
                  <%= if is_correct do %>
                    <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-green-100 text-green-800">
                      ✓ Correct
                    </span>
                  <% else %>
                    <span class="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-red-100 text-red-800">
                      ✗ Incorrect
                    </span>
                  <% end %>
                </div>
                <p class="text-gray-800"><%= question.question %></p>
              </div>

              <!-- User's Answer -->
              <div class="mb-4 p-4 bg-gray-50 rounded border border-gray-200">
                <p class="text-sm font-medium text-gray-700 mb-1">Your Answer:</p>
                <p class={["text-gray-900", not is_correct and "text-red-700"]}>
                  <%= user_answer %>
                </p>
              </div>

              <!-- User's Motivation -->
              <div class="mb-4 p-4 bg-gray-50 rounded border border-gray-200">
                <p class="text-sm font-medium text-gray-700 mb-1">Your Reasoning:</p>
                <p class="text-gray-700"><%= Map.get(@user_motivations, question.id) %></p>
              </div>

              <!-- Correct Answer -->
              <div class={["p-4 rounded border-l-4 mb-4", is_correct and "bg-green-50 border-l-green-500", not is_correct and "bg-red-50 border-l-red-500"]}>
                <p class={["text-sm font-medium mb-1", is_correct and "text-green-900", not is_correct and "text-red-900"]}>
                  <%= if is_correct do %>
                    ✓ Your answer was correct
                  <% else %>
                    ✗ Correct Answer:
                  <% end %>
                </p>
                <p class={["font-semibold", is_correct and "text-green-900", not is_correct and "text-red-900"]}>
                  <%= question.correct_answer %>
                </p>
              </div>

              <!-- Official Explanation -->
              <div class="p-4 bg-blue-50 rounded border border-blue-200">
                <p class="text-sm font-medium text-blue-900 mb-2">Explanation:</p>
                <p class="text-blue-900"><%= question.motivation %></p>
              </div>
            </div>
          <% end %>
        </div>

        <!-- Retake Button -->
        <div class="flex justify-center mt-8">
          <button
            phx-click="retake_quiz"
            class="px-8 py-3 bg-blue-600 hover:bg-blue-700 text-white font-semibold rounded-lg transition-colors"
          >
            Retake Quiz
          </button>
        </div>
      </div>
    </QuizAppWeb.Layouts.app>
    """
  end

  @impl true
  def handle_event("answer_selected", %{"question-id" => question_id_str, "answer" => answer}, socket) do
    question_id = String.to_integer(question_id_str)
    user_answers = Map.put(socket.assigns.user_answers, question_id, answer)
    {:noreply, assign(socket, :user_answers, user_answers)}
  end

  @impl true
  def handle_event("motivation_changed", %{"question-id" => question_id_str, "value" => motivation}, socket) do
    question_id = String.to_integer(question_id_str)
    user_motivations = Map.put(socket.assigns.user_motivations, question_id, motivation)
    {:noreply, assign(socket, :user_motivations, user_motivations)}
  end

  @impl true
  def handle_event("submit_quiz", _params, socket) do
    user_answers = socket.assigns.user_answers
    questions = socket.assigns.questions

    if is_quiz_complete?(user_answers, socket.assigns.user_motivations, length(questions)) do
      score = calculate_score(questions, user_answers)

      socket =
        socket
        |> assign(:quiz_submitted, true)
        |> assign(:final_score, score)

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("retake_quiz", _params, socket) do
    questions = Quiz.get_random_questions(10)

    socket =
      socket
      |> assign(:questions, questions)
      |> assign(:user_answers, %{})
      |> assign(:user_motivations, %{})
      |> assign(:quiz_submitted, false)
      |> assign(:final_score, nil)

    {:noreply, socket}
  end

  # Helper: Check if all questions are answered and have motivations
  defp is_quiz_complete?(user_answers, user_motivations, total_questions) do
    answers_complete = map_size(user_answers) == total_questions
    motivations_complete = map_size(user_motivations) == total_questions

    if answers_complete and motivations_complete do
      # Verify no empty motivations
      Enum.all?(user_motivations, fn {_key, motivation} ->
        String.trim(motivation) != ""
      end)
    else
      false
    end
  end

  # Helper: Calculate final score
  defp calculate_score(questions, user_answers) do
    Enum.count(questions, fn question ->
      user_answer = Map.get(user_answers, question.id)
      user_answer == question.correct_answer
    end)
  end
end

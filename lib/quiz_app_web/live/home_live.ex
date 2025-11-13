defmodule QuizAppWeb.HomeLive do
  use QuizAppWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-md mx-auto py-12">
      <div class="bg-white rounded-lg shadow-md p-8 text-center">
        <h1 class="text-3xl font-bold text-gray-900 mb-4">Welcome to Quiz</h1>
        <p class="text-gray-600 mb-6">
          Test your knowledge with our interactive quiz. Answer 10 questions and get immediate feedback.
        </p>
        <.link navigate="/quiz" class="inline-block px-6 py-3 bg-blue-600 hover:bg-blue-700 text-white font-semibold rounded-lg transition-colors">
          Start Quiz
        </.link>
      </div>
    </div>
    """
  end
end

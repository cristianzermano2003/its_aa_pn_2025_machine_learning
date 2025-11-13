defmodule QuizAppWeb.ErrorJSON do
  def render(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end

defmodule QuizAppWeb.ErrorHTML do
  use QuizAppWeb, :html

  def render(template, assigns) do
    assigns = assign(assigns, :template, template)

    ~H"""
    <div class="min-h-screen flex items-center justify-center bg-gray-50">
      <div class="text-center">
        <h1 class="text-4xl font-bold text-gray-900 mb-2">Error</h1>
        <p class="text-gray-600 mb-6">
          <%= Phoenix.Controller.status_message_from_template(@template) %>
        </p>
        <.link navigate="/" class="inline-block px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded">
          Go Home
        </.link>
      </div>
    </div>
    """
  end
end

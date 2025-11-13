defmodule QuizAppWeb.CoreComponents do
  use Phoenix.Component

  def get_csrf_token do
    Plug.CSRFProtection.get_csrf_token()
  end

  @doc """
  Renders a flashgroup including all flash types with a dismiss button.
  """
  attr :flash, :map, required: true
  attr :rest, :global

  def flash_group(assigns) do
    ~H"""
    <div {@rest}>
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />
    </div>
    """
  end

  @doc """
  Renders flash messages.
  """
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :kind, :atom, values: [:info, :error], doc: "the kind of flash message"

  def flash(%{kind: kind} = assigns) do
    message = Phoenix.Flash.get(assigns.flash, kind)

    assigns = assign(assigns, :message, message)

    ~H"""
    <%= if @message do %>
      <div class="relative bg-white p-4 mb-4 rounded-lg border-l-4"
           role="alert"
           phx-click="lv:clear-flash"
           phx-value-key={@kind}>
        <p class="text-sm font-medium"><%= @message %></p>
      </div>
    <% end %>
    """
  end

  @doc """
  Renders an input with label and error messages.
  """
  attr :id, :string
  attr :name, :string
  attr :label, :string
  attr :value, :any
  attr :type, :string, default: "text"
  attr :field, Phoenix.HTML.FormField
  attr :errors, :list, default: []
  attr :checked, :boolean
  attr :prompt, :string
  attr :options, :list
  attr :multiple, :boolean, default: false
  attr :disabled, :boolean, default: false
  attr :class, :string, default: ""
  attr :rest, :global, include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength pattern placeholder readonly required rows size src step)

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
    |> assign_new(:name, fn -> field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "checkbox"} = assigns) do
    ~H"""
    <div class="flex items-center gap-2">
      <input
        type="checkbox"
        id={@id}
        name={@name}
        value="true"
        checked={@value}
        {@rest}
        class="rounded border-gray-300"
      />
      <label for={@id} class="text-sm font-medium text-gray-700">
        <%= @label %>
      </label>
    </div>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div>
      <label for={@id} class="block text-sm font-medium text-gray-700">
        <%= @label %>
      </label>
      <select
        id={@id}
        name={@name}
        multiple={@multiple}
        disabled={@disabled}
        {@rest}
        class="mt-1 block w-full rounded border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 text-sm"
      >
        <option :if={@prompt} value=""><%= @prompt %></option>
        <option :for={{label, value} <- @options} value={value} selected={value == @value}>
          <%= label %>
        </option>
      </select>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div>
      <label for={@id} class="block text-sm font-medium text-gray-700">
        <%= @label %>
      </label>
      <textarea
        id={@id}
        name={@name}
        disabled={@disabled}
        {@rest}
        class={["mt-1 block w-full rounded border border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 text-sm p-2", @class]}
      ><%= @value %></textarea>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def input(%{type: "radio"} = assigns) do
    ~H"""
    <div class="flex items-center gap-2">
      <input
        type="radio"
        id={@id}
        name={@name}
        value={@value}
        checked={@checked}
        disabled={@disabled}
        {@rest}
        class="rounded border-gray-300"
      />
      <label for={@id} class="text-sm text-gray-700">
        <%= @label %>
      </label>
    </div>
    """
  end

  def input(assigns) do
    ~H"""
    <div>
      <label for={@id} class="block text-sm font-medium text-gray-700">
        <%= @label %>
      </label>
      <input
        type={@type}
        id={@id}
        name={@name}
        value={@value}
        disabled={@disabled}
        {@rest}
        class={["mt-1 block w-full rounded border border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 text-sm px-3 py-2", @class]}
      />
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  @doc """
  Renders a button.
  """
  attr :type, :string, default: "button"
  attr :class, :string, default: ""
  attr :disabled, :boolean, default: false
  attr :rest, :global, include: ~w(disabled form name value phx-click phx-target phx-disable-with)

  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <button
      type={@type}
      disabled={@disabled}
      class={[
        "inline-flex items-center justify-center px-4 py-2 rounded-lg font-medium text-white transition-colors",
        "bg-blue-600 hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </button>
    """
  end

  @doc """
  Renders an error message.
  """
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def error(assigns) do
    ~H"""
    <p class={["text-sm font-medium text-red-600 mt-1", @assigns.class]}>
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end

  defp translate_error(msg) do
    msg
  end
end

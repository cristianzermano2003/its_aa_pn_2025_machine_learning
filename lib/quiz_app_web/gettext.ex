defmodule QuizAppWeb.Gettext do
  @moduledoc """
  A module providing Internationalization with a default locale of :en.
  """
  use Gettext.Backend, otp_app: :quiz_app
end

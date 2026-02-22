defmodule CinderUI.Storybook do
  @moduledoc """
  Storybook helpers for integrating Cinder UI previews into a Phoenix app.

  ## Host App Usage

      defmodule MyAppWeb.Storybook do
        use PhoenixStorybook,
          otp_app: :my_app,
          content_path: CinderUI.Storybook.content_path(),
          css_path: "/assets/app.css",
          js_path: "/assets/app.js"
      end

  If you want to customize stories, copy the folder returned by
  `content_path/0` into your application's own storybook directory.
  """

  @doc """
  Returns the absolute path to bundled `.story.exs` files.
  """
  @spec content_path() :: String.t()
  def content_path do
    Path.expand("../../storybook", __DIR__)
  end
end

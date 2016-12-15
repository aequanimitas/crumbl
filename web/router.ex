defmodule Crumbl.Router do
  use Crumbl.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Crumbl.Auth, repo: Crumbl.Repo
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Crumbl do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/users", UserController, only: [:index, :show, :new, :create]
    resources "/session", SessionController, only: [:delete, :new, :create]
  end

  scope "/manage", Crumbl do
    pipe_through [:browser, :authenticate_user]
    resources "/videos", VideoController
  end

  # Other scopes may use custom stacks.
  # scope "/api", Crumbl do
  #   pipe_through :api
  # end
end

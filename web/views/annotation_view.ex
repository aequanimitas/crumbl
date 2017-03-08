defmodule Crumbl.AnnotationView do
  use Crumbl.Web, :view

  def render("annotation.json", %{annotation: ann}) do
    %{
      id: ann.id,
      body: ann.body,
      at: ann.at,
      user: render_one(ann.user, Crumbl.UserView, "user.json")
    }
  end
end

defmodule Phoenix.Router.NestedTest do
  use ExUnit.Case, async: true
  use ConnHelper

  setup do
    Logger.disable(self())
    :ok
  end

  defmodule UserController do
    use Phoenix.Controller
    def show(conn, _params), do: text(conn, "show users")
    def index(conn, _params), do: text(conn, "index users")
    def new(conn, _params), do: text(conn, "new users")
    def edit(conn, _params), do: text(conn, "edit users")
    def create(conn, _params), do: text(conn, "create users")
    def update(conn, _params), do: text(conn, "update users")
    def destroy(conn, _params), do: text(conn, "destroy users")
  end

  defmodule FileController do
    use Phoenix.Controller
    def show(conn, _params), do: text(conn, "show files")
    def index(conn, _params), do: text(conn, "index files")
    def new(conn, _params), do: text(conn, "new files")
    def create(conn, _params), do: text(conn, "create files")
    def update(conn, _params), do: text(conn, "update files")
    def destroy(conn, _params), do: text(conn, "destroy files")
  end

  defmodule CommentController do
    use Phoenix.Controller
    def show(conn, _params), do: text(conn, "show comments")
    def index(conn, _params), do: text(conn, "index comments")
    def new(conn, _params), do: text(conn, "new comments")
    def create(conn, _params), do: text(conn, "create comments")
    def update(conn, _params), do: text(conn, "update comments")
    def destroy(conn, _params), do: text(conn, "destroy comments")
    def special(conn, _params), do: text(conn, "special comments")
  end

  defmodule SessionController do
    use Phoenix.Controller

    def new(conn, _params), do: text(conn, "session login")
    def create(conn, _params), do: text(conn, "session created")
    def destroy(conn, _params), do: text(conn, "session destroyed")
  end

  defmodule PostController do
    use Phoenix.Controller
    def show(conn, _params), do: text(conn, "show posts")
    def new(conn, _params), do: text(conn, "new posts")
    def index(conn, _params), do: text(conn, "index posts")
    def create(conn, _params), do: text(conn, "create posts")
    def update(conn, _params), do: text(conn, "update posts")
  end

  defmodule PageController do
    use Phoenix.Controller
    def show(conn, _params), do: text(conn, "show page")
  end

  defmodule RatingController do
    use Phoenix.Controller
    def show(conn, _params), do: text(conn, "show rating")
  end

  defmodule Router do
    use Phoenix.Router

    resources "/users", UserController do
      resources "/comments", CommentController do
        get "/special", CommentController, :special
      end
      resources "/files", FileController
      resources "/posts", PostController, except: [ :destroy ]
      resources "/sessions", SessionController, only: [ :new, :create, :destroy ]
    end

    resources "/files", FileController, name: "asset" do
      resources "/comments", CommentController do
        get "/avatar", Users, :avatar
      end
    end

    resources "/scoped_files", FileController, only: [:index] do
      resources "/comments", CommentController, except: [:destroy]
    end

    resources "/pages", PageController, param: "slug", name: "area" do
      resources "/ratings", RatingController, param: "key", name: "vote"
    end
  end

  test "toplevel route matches new action" do
    conn = call(Router, :get, "users/new")
    assert conn.status == 200
    assert conn.resp_body == "new users"
  end

  test "toplevel route matches index action" do
    conn = call(Router, :get, "users")
    assert conn.status == 200
    assert conn.resp_body == "index users"
  end

  test "toplevel route matches show action with named param" do
    conn = call(Router, :get, "users/123")
    assert conn.status == 200
    assert conn.resp_body == "show users"
    assert conn.params["id"] == "123"
  end

  test "toplevel route matches edit action with named param" do
    conn = call(Router, :get, "users/123/edit")
    assert conn.status == 200
    assert conn.resp_body == "edit users"
    assert conn.params["id"] == "123"
  end

  test "toplevel route matches create action" do
    conn = call(Router, :post, "users")
    assert conn.status == 200
    assert conn.resp_body == "create users"
  end

  test "toplevel route matches update action" do
    conn = call(Router, :put, "users/1")
    assert conn.status == 200
    assert conn.resp_body == "update users"
    assert conn.params["id"] == "1"

    conn = call(Router, :patch, "users/2")
    assert conn.status == 200
    assert conn.resp_body == "update users"
    assert conn.params["id"] == "2"
  end

  test "toplevel route matches destroy action" do
    conn = call(Router, :delete, "users/2")
    assert conn.status == 200
    assert conn.resp_body == "destroy users"
    assert conn.params["id"] == "2"
  end

  test "1-Level nested route matches with named param prefix on show" do
    conn = call(Router, :get, "users/1/comments/2")
    assert conn.status == 200
    assert conn.resp_body == "show comments"
    assert conn.params["id"] == "2"
    assert conn.params["user_id"] == "1"
  end

  test "1-Level nested route matches with named param prefix on index" do
    conn = call(Router, :get, "users/1/comments")
    assert conn.status == 200
    assert conn.resp_body == "index comments"
    assert conn.params["user_id"] == "1"
  end

  test "1-Level nested route matches with named param prefix on create" do
    conn = call(Router, :post, "users/1/comments")
    assert conn.status == 200
    assert conn.resp_body == "create comments"
    assert conn.params["user_id"] == "1"
  end

  test "1-Level nested route matches with named param prefix on update" do
    conn = call(Router, :put, "users/1/comments/123")
    assert conn.status == 200
    assert conn.resp_body == "update comments"
    assert conn.params["user_id"] == "1"
    assert conn.params["id"] == "123"
  end

  test "1-Level nested route matches with named param prefix on destroy" do
    conn = call(Router, :delete, "users/1/comments/123")
    assert conn.status == 200
    assert conn.resp_body == "destroy comments"
    assert conn.params["user_id"] == "1"
    assert conn.params["id"] == "123"
  end

  test "2-Level nested route with get matches" do
    conn = call(Router, :get, "users/1/comments/123/special")
    assert conn.status == 200
    assert conn.resp_body == "special comments"
    assert conn.params["user_id"] == "1"
    assert conn.params["comment_id"] == "123"
  end

  test "nested prefix context reverts back to previous scope after expansion" do
    conn = call(Router, :get, "users/8/files/10")
    assert conn.status == 200
    assert conn.resp_body == "show files"
    assert conn.params["user_id"] == "8"
    assert conn.params["id"] == "10"

    conn = call(Router, :get, "files")
    assert conn.status == 200
    assert conn.resp_body == "index files"
  end

  test "nested options limit resource by passing :except option" do
    conn = call(Router, :delete, "users/1/posts/2")
     assert conn.status == 404
    conn = call(Router, :get, "users/1/posts/new")
    assert conn.status == 200
  end

  test "nested options limit resource by passing :only option" do
    conn = call(Router, :put, "users/1/sessions/2")
     assert conn.status == 404
    conn = call(Router, :get, "users/1/sessions/")
     assert conn.status == 404
    conn = call(Router, :get, "users/1/sessions/1")
     assert conn.status == 404
    conn = call(Router, :get, "users/1/sessions/new")
    assert conn.status == 200
    conn = call(Router, :post, "users/1/sessions")
    assert conn.status == 200
    conn = call(Router, :delete, "users/1/sessions/1")
    assert conn.status == 200
  end

  test "resource limiting options should work for nested resources" do
    conn = call(Router, :get, "scoped_files")
    assert conn.status == 200
    assert conn.resp_body == "index files"

    conn = call(Router, :get, "scoped_files/1")
    assert conn.status == 404
    conn = call(Router, :put, "scoped_files/1")
    assert conn.status == 404
    conn = call(Router, :post, "scoped_files")
    assert conn.status == 404
    conn = call(Router, :delete, "scoped_files/1")
    assert conn.status == 404

    conn = call(Router, :get, "scoped_files/1/comments")
    assert conn.status == 200
    assert conn.resp_body == "index comments"

    conn = call(Router, :get, "scoped_files/1/comments/1")
    assert conn.status == 200
    assert conn.resp_body == "show comments"

    conn = call(Router, :put, "scoped_files/1/comments/1")
    assert conn.status == 200
    assert conn.resp_body == "update comments"

    conn = call(Router, :post, "scoped_files/1/comments")
    assert conn.status == 200
    assert conn.resp_body == "create comments"

    conn = call(Router, :delete, "scoped_files/1")
    assert conn.status == 404
  end

  test "param option allows default singularlized _id param to be overidden" do
    conn = call(Router, :get, "pages/about")
    assert conn.status == 200
    assert conn.params["slug"] == "about"
    assert conn.resp_body == "show page"
    assert Router.Helpers.area_path(:show, "about") ==
           "/pages/about"

    conn = call(Router, :get, "pages/contact/ratings/the_key")
    assert conn.status == 200
    assert conn.params["area_slug"] == "contact"
    assert conn.params["key"] == "the_key"
    assert conn.resp_body == "show rating"
    assert Router.Helpers.area_vote_path(:show, "contact", "the_key") ==
           "/pages/contact/ratings/the_key"
  end
end


# Elixir/Phoenix Implementation for [Todo-Backend](http://www.todobackend.com/)

Deployed to http://todobackend-phoenix.herokuapp.com/api/todos

Tested against [Todo-Backend API tests](http://www.todobackend.com/specs/index.html?http://todobackend-phoenix.herokuapp.com/api/todos)

Here's a step-by-step guide to implementing an Elixir/Phoenix Todo-Backend deployed to Heroku.

## First, let's create our new Phoenix project

```shell
$ mix phoenix.new todobackend
* creating todobackend/config/config.exs
* creating todobackend/config/dev.exs
* creating todobackend/config/prod.exs
* creating todobackend/config/prod.secret.exs
* creating todobackend/config/test.exs
* creating todobackend/lib/todobackend.ex
* creating todobackend/lib/todobackend/endpoint.ex
* creating todobackend/test/controllers/page_controller_test.exs
* creating todobackend/test/views/error_view_test.exs
* creating todobackend/test/views/page_view_test.exs
* creating todobackend/test/support/conn_case.ex
* creating todobackend/test/test_helper.exs
* creating todobackend/web/controllers/page_controller.ex
* creating todobackend/web/templates/layout/application.html.eex
* creating todobackend/web/templates/page/index.html.eex
* creating todobackend/web/views/error_view.ex
* creating todobackend/web/views/layout_view.ex
* creating todobackend/web/views/page_view.ex
* creating todobackend/web/router.ex
* creating todobackend/web/web.ex
* creating todobackend/mix.exs
* creating todobackend/README.md
* creating todobackend/lib/todobackend/repo.ex
* creating todobackend/test/support/model_case.ex
* creating todobackend/.gitignore
* creating todobackend/brunch-config.js
* creating todobackend/package.json
* creating todobackend/web/static/css/app.scss
* creating todobackend/web/static/js/app.js
* creating todobackend/web/static/vendor/phoenix.js
* creating todobackend/priv/static/images/phoenix.png

Install mix dependencies? [Yn] Y
* running mix deps.get

Install brunch.io dependencies? [Yn] Y
* running npm install

We are all set! Run your Phoenix application:

    $ cd todobackend
    $ mix phoenix.server

You can also run it inside IEx (Interactive Elixir) as:

    $ iex -S mix phoenix.server

```

Let's go ahead and commit the base application
```shell
$ cd todobackend
$ git init
$ git add .
$ git commit -m "initial phoenix 0.12 application"
```


## Next, let's get it ready for Heroku
First we'll provision our Heroku application
```shell
$ heroku create --buildpack "https://github.com/HashNuke/heroku-buildpack-elixir.git" --app todobackend-phoenix
```

We'll rebuild our app for every dyno restart, for now, at least.
```
# Procfile
web: mix clean && mix phoenix.server
```

We'll set our app to use the database that the Heroku buildpack includes
```elixir
# config/prod.secret.exs
config :todobackend, Todobackend.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: {:system, "DATABASE_URL"},
  size: 20 # The amount of database connections in the pool
```

Heroku has our app running behind a routing layer, so our app runs on a non-standard port and doesn't really know its hostname. Let's set those for when we generate full urls for the client.
```elixir
# config/prod.exs
config :todobackend, Todobackend.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [host: "todobackend-phoenix.herokuapp.com", port: 80],
  cache_static_manifest: "priv/static/manifest.json"
```

We'll also create the digest versions of our assets now
```shell
$ mix phoenix.digest
```

Let's add and commit all the files. Since `config/prod.secrets.exs` was initially included in `.gitignore`, we'll need to tell git, that we do indeed want it versioned.
And then we'll ship what we have to Heroku
```shell
$ git add .
$ git add -f config/prod.secret.exs
$ git commit -m "prep for Heroku"
$ git push heroku master
$ heroku open
```

## Create the Todo model

```shell
$ mix phoenix.gen.json Todo todos title:string order:integer completed:boolean
```

If you want to go ahead and run `mix ecto.create` and `mix ecto.migrate` for your local development database, you may.
We'll tell Heroku to in a few minutes

```elixir
# web/router.ex
  scope "/api", Todobackend do
    pipe_through :api
    resources "/todos", TodoController
  end
```

```shell
$ git add .
$ git commit -m "add initial Todo model"
$ git push heroku master
$ heroku run mix ecto.create
$ heroku run mix ecto.migrate
```

Note: `heroku run mix ecto.create` may return an error like `** (Mix) The database for Todobackend.Repo couldn't be created, reason given: Error: You must install at least one postgresql-client-<version> package.`
That's ok. The command probably still worked and you should be able to proceed with `heroku run mix ecto.migrate`.

If we run the [Todo-Backend tests against our new service](http://www.todobackend.com/specs/index.html?http://todobackend-phoenix.herokuapp.com/api/todos), they'll fail because we haven't enabled CORS yet.

## Add CORS
```elixir
# web/router.ex
  def cors(conn, _opts) do
    conn
    |> put_resp_header("Access-Control-Allow-Origin", "*")
    |> put_resp_header("Access-Control-Allow-Headers", "Content-Type")
    |> put_resp_header("Access-Control-Allow-Methods", "GET,PUT,PATCH,OPTIONS,DELETE,POST")
  end
```

```elixir
# web/router.ex
  pipeline :api do
    plug :cors
    plug :accepts, ["json"]
  end
```

TodoBackend's CORS test will also require the `OPTIONS` HTTP verb for the Todos

```elixir
# web/router
  scope "/api", Todobackend do
    pipe_through :api
    resources "/todos", TodoController
    options "/todos", TodoController, :options
    options "/todos/:id", TodoController, :options
  end
```

```elixir
# web/controllers/todo_controller.ex
  def options(conn, _params) do
    conn
    |> send_resp(200, "GET,POST,DELETE,OPTIONS,PUT")
  end
```

```shell
$ git add .
$ git commit -m "add CORS support"
$ git push heroku master
```

Yay! Our first TodoBackend test passes!

## Adjust the JSON serialization of Todo

We don't need any of the parameters scrubbed for logging for this app, so let's remove it.

```elixir
# web/controllers/todo_controller.ex

  # plug :scrub_params, "todo" when action in [:create, :update]
  plug :action
```

We also have a mismatch between what Phoenix expects by default and what the Todo Frontend is sending. By default Phoenix expects our Todo to look like the following.
```json
{ "todo":
  { "order": 10, 
    "title": "blah"
  }
}
```

The Todo Frontend is only sending that inner bit, so let's excise the outer bit from our controller.
```elixir
# web/controllers/todo_controller.ex
  def create(conn, todo_params) do
# ...
  def update(conn, todo_params = %{"id" => id}) do
```

Similarly, for the response, by default Phoenix will nest our Todo model under `data` like the following.
```json
{ "data":
  { "id": 1
  }
}
```

Let's edit the TodoView to remove the `data` and to add more attributes other than `id`.
```elixir
# web/views/todo_view.ex
  def render("index.json", %{todos: todos}) do
    render_many(todos, "todo.json")
  end

  def render("show.json", %{todo: todo}) do
    render_one(todo, "todo.json")
  end

  def render("todo.json", %{todo: todo}) do
    %{id: todo.id,
      title: todo.title,
      order: todo.order,
      completed: todo.completed,
      url: todo_url(Todobackend.Endpoint, :show, todo),
    }
  end
```

We also want to specify that `order` and `completed` are optional fields.
```elixir
# web/models/todo.ex
  @required_fields ~w(title)
  @optional_fields ~w(order completed)
```

```shell
$ git add .
$ git commit -m "match JSON serialization of Todo to structure of client's expectations"
$ git push heroku master
```

Whoa! All of a sudden 3 tests pass now!

## Add Delete All

Todo Frontend expects us to implement a `delete all` if we receive `DELETE /api/todos`. This functionality isn't part of the Phoenix `resources`, so we'll need to add it.
```elixir
# web/router.ex
  scope "/api", Todobackend do
    pipe_through :api
    resources "/todos", TodoController
    options "/todos", TodoController, :options
    options "/todos/:id", TodoController, :options
    delete "/todos", TodoController, :delete_all
  end
```

```elixir
# web/controllers/todo_controller.ex
 def delete_all(conn, _params) do
    Repo.delete_all(Todo)

    todos = Repo.all(Todo)
    render(conn, "index.json", todos: todos)
  end
```

```shell
$ git add .
$ git commit -m "implement delete all"
$ git push heroku master
```

Holy Smokes! All the tests pass now. Congratulations!

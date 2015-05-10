use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
config :todobackend, Todobackend.Endpoint,
  secret_key_base: "s7NCSZCdBgNYIhtri0IoempTZ9DqOeVaG3qJGKOyJGoLHLVLFDj2udpk0BdBZgHY"

# Configure your database
config :todobackend, Todobackend.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: {:system, "DATABASE_URL"},
  size: 20 # The amount of database connections in the pool

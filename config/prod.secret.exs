use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
config :todobackend, Todobackend.Endpoint,
  secret_key_base: "vpn9ohOdmRWAM/E1A5uYCW77Bx7NxBVsPWFBI6XjVu6zfPZVcpcVeDhPFQlSitng"

# Configure your database
config :todobackend, Todobackend.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DATABASE_USERNAME"),
  password: System.get_env("DATABASE_PASSWORD"),
  database: System.get_env("DATABASE_NAME"),
  hostname: System.get_env("DATABASE_HOSTNAME"),
  size: 20 # The amount of database connections in the pool

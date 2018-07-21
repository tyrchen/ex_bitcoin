use Mix.Config

config :ex_bitcoin,
  conn: %{
    hostname: "localhost",
    port: 8332,
    user: System.get_env("BITCOIN_RPC_USER"),
    password: System.get_env("BITCOIN_RPC_PASS")
  }

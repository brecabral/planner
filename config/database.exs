import Config

env_file = Path.expand("../.env", __DIR__)

env =
  if File.exists?(env_file) do
    env_file
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == "" or String.starts_with?(&1, "#")))
    |> Map.new(fn line ->
      case String.split(line, "=", parts: 2) do
        [key, value] ->
          if Regex.match?(~r/^[A-Z_][A-Z0-9_]*$/, key) and
               Regex.match?(~r/^[a-zA-Z0-9_.:\/@%+=,-]+$/, value) do
            {key, value}
          else
            raise "Formato inválido no .env: use KEY=value sem aspas ou interpolação"
          end

        _ ->
          raise "Formato inválido no .env: use KEY=value"
      end
    end)
  else
    %{}
  end

fetch_env = fn key ->
  System.get_env(key) || Map.get(env, key) ||
    raise "Defina #{key} no ambiente ou no .env (veja .env.example)"
end

database =
  if config_env() == :test do
    fetch_env.("POSTGRES_TEST_DB") <> System.get_env("MIX_TEST_PARTITION", "")
  else
    fetch_env.("POSTGRES_DB")
  end

config :planner, Planner.Repo,
  username: fetch_env.("POSTGRES_USER"),
  password: fetch_env.("POSTGRES_PASSWORD"),
  hostname: fetch_env.("POSTGRES_HOST"),
  port: String.to_integer(fetch_env.("POSTGRES_PORT")),
  database: database

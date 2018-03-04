defmodule ExBitcoinUtils.Gen do
  @moduledoc """
  Documentation for ExBitcoin.
  """
  alias ExBitcoinUtils, as: Utils
  alias ExBitcoinUtils.Rpc

  defmacro module(path) do
    quote bind_quoted: [path: path] do
      %{"ns" => ns, "desc" => mdoc, "items" => items} = Utils.load_json(path)

      contents =
        items
        |> Enum.map(fn %{"name" => name, "desc" => fdoc, "args" => args} ->
          quote do
            @spec unquote(String.to_atom(name))(unquote_splicing(Utils.gen_spec(args))) :: any
            @doc unquote(fdoc)
            def unquote(String.to_atom(name))(unquote_splicing(Utils.gen_args(args, ExBitcoin))) do
              args = Enum.map(binding(), fn {_, v} -> v end)
              Rpc.request(unquote(String.to_atom(name)), args)
            end
          end
        end)

      moduledoc = quote do
        @moduledoc unquote(mdoc)
      end

      name = String.to_atom("Elixir.ExBitcoin.#{ns}")
      Module.create(name, [moduledoc] ++ [contents], Macro.Env.location(__ENV__))
    end

  end

end

defmodule ExBitcoinTask.GenerateRpc.SingleCmd do
  @moduledoc """
  Process document for a single bitcoin cli.
  """

  import AutoError
  require Logger
  @default_type %{"type" => "", "required" => true, "default" => nil}

  def format_response(data) do
    {:ok, data}
    ~>> breakdown
    ~>> extract_fn
    ~>> extract_args
    ~> Map.delete("_args")
  end

  defp extract_fn(data) do
    fn_name =
      {:ok, data}
      ~> Map.fetch("desc")
      ~>> get_first("\n")
      ~>> get_first(" ")

    case fn_name do
      {:ok, name} -> Map.put(data, "name", name)
      err -> Logger.error("Failed to get function name: #{inspect(err)}")
    end
  end

  defp extract_args(%{"_args" => ""} = data), do: data

  defp extract_args(%{"name" => "getmemoryinfo"} = data) do
    Map.put(data, "args", [
      %{
        "default" => "stats",
        "desc" => "determines what kind of information is returned.",
        "name" => "mode",
        "required" => false,
        "type" => "string"
      }
    ])
  end

  defp extract_args(data) do
    result =
      {:ok, data}
      ~> Map.fetch("_args")
      ~>> get_first("\n\n")
      ~>> split_args
      ~>> Enum.map(&extract_arg/1)

    case result do
      {:ok, args} ->
        Map.put(data, "args", args)

      err ->
        Logger.error("Failed to get function args: #{inspect(err)}")
        data
    end
  end

  defp get_first(str, sep), do: str |> String.split(sep) |> List.first()

  defp split_args(str) do
    result = Regex.replace(~r/\n(?!\d+)/, str, " ")
    String.split(result, "\n")
  end

  defp extract_arg(str) do
    regex = ~r/\d*\.\s*\"*(?<name>[^"\s]+)\"*\s*\(\s*(?<data>[^)]+)\)\s*(?<desc>.+)*/

    regex
    |> Regex.named_captures(str)
    |> transform
  end

  defp transform(capture) do
    data =
      capture
      |> Map.get("data")
      |> String.split(",")
      |> Enum.map(&String.trim/1)
      |> process_type

    capture
    |> Map.delete("data")
    |> Map.merge(Map.merge(@default_type, data))
  end

  defp process_type([type]) do
    %{"type" => transform_type(type)}
  end

  defp process_type([type, required]) do
    is_required =
      if required == "optional" do
        false
      else
        true
      end

    Map.merge(process_type([type]), %{"required" => is_required})
  end

  defp process_type([type, required | rest]) do
    default =
      case Enum.find(rest, nil, &String.starts_with?(&1, "default")) do
        nil -> nil
        v -> Regex.replace(~r/default\s*=\s*/, v, "")
      end

    Map.merge(process_type([type, required]), %{"default" => default})
  end

  defp transform_type(type) do
    type
  end

  defp breakdown(data) do
    map = %{"_args" => "", "desc" => data, "name" => "", "args" => []}

    case String.split(data, "Arguments:\n") do
      [_doc] -> map
      [_, args] -> Map.put(map, "_args", args)
    end
  end

  # defp breakdown(data) do
  #   regex1 = ~r/^(?<desc>.*?(?=Arguments))Arguments:(?<args>.*?(?=Examples))Examples:.*?(?=data-binary)data-binary\s*'(?<json>[^']+)'/
  #   regex2 = ~r/^(?<desc>.*?(?=Examples))Examples:.*?(?=data-binary)data-binary\s*'(?<json>[^']+)'/
  #   regex3 = ~r/^(?<desc>.*?(?=Arguments))Arguments:(?<args>.+)/
  #   case Regex.named_captures(regex1, data) do
  #     nil ->
  #       case Regex.named_captures(regex2, data) do
  #         nil ->
  #           result = Regex.named_captures(regex3, data)
  #           result
  #           |> Map.put("json", "")
  #           |> Map.put("function", %{"name" => "", "args" => []})
  #         result ->
  #           result
  #           |> Map.put("args", "")
  #           |> Map.put("function", %{"name" => "", "args" => []})
  #       end
  #     result ->
  #       Map.put(result, "function", %{"name" => "", "args" => []})
  #   end
  # end

  # @sep_from "\n"
  # @sep_to "$@@$"
  #
  # defp patch(data), do: String.replace(data, @sep_from, @sep_to)
  #
  # defp unpatch(data) when is_binary(data), do: data |> String.replace(@sep_to, @sep_from) |> String.trim
  # defp unpatch(data) when is_list(data), do: Enum.map(data, &unpatch/1)
  # defp unpatch(data) when is_map(data), do: data |> Enum.map(fn {k, v} -> {k, unpatch(v)} end) |> Enum.into(%{})
end

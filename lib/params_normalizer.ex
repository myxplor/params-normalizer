defmodule ParamsNormalizer do
  @moduledoc """
  Handles normalization of params from controllers/channels
  """

  @doc """
  Takes in a list of maps.

  Each map has a `:path` key with is a path to the value to be proccess.

  E.g. if you wanted to process "id" in:

  ```elixir
  iex> %{
    "data" => %{
      "attributes" => %{
        "id" => "3"
      }
    }
  }
  ```

  The path would look like: `["data", "attributes", "id"]`

  The second k/v pair is a function that takes in the value and
  either returns `{:ok, processed_value}` or `{:error, "reason"}`

  This procced value will be put  back into the same position
  as it was retrieved from.

  E.g.

  ```elixir
  iex> validations = [
    %{path: ["data", "attributes", "id"], process: &string_to_integer/1}
  ]

  iex> params = %{
    "data" => %{
      "attributes" => %{
        "id" => "3"
      }
    }
  }

  iex> ParamsNormalizer.validate_and_normalize_params(params, validations)
    {:ok, %{
      "data" => %{
        "attributes" => %{
          "id" => 3
        }
      }
    }

  iex> params = %{
    "data" => %{
      "attributes" => %{
        "id" => ["3"]
      }
    }
  }

  iex> ParamsNormalizer.validate_and_normalize_params(params, validations)
    {:error, :invalid_params, %{"data.attributes.id" => "can't be cast to integer"}}
  ```
  """
  def validate_and_normalize_params(params_map, field_validations) do
    process_field = fn(%{path: params_path, process: process_param_func}, acc) ->
      value = get_in(params_map, params_path)

      case process_param_func.(value) do
        {:ok, processed_value} -> put_in(acc, params_path, processed_value)
        {:error, error} ->
          path_string = Enum.join(params_path, ".")
          %{acc | errors: Map.put(acc[:errors], path_string, error)}
      end
    end

    field_validations
    |> Enum.reduce(Map.merge(params_map, %{errors: %{}}), process_field)
    |> check_for_errors()
  end

  @doc """
  Handles the casting of a string to an integer and will return an error tuple
  if the process fails.
  """
  def string_to_integer(val) when is_integer(val), do: {:ok, val}
  def string_to_integer(val) do
    {:ok, String.to_integer(val)}
    rescue
      _ -> {:error, "can't cast value to integer"}
  end

  # ---------------------------------
  #
  # HELPERS
  #
  # --------------------------------
  defp check_for_errors(%{errors: errors} = params) when errors == %{}, do: {:ok, Map.delete(params, :errors)}
  defp check_for_errors(%{errors: errors}), do: {:error, :invalid_params, errors}
end

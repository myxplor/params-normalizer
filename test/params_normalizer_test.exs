defmodule ParamsNormalizerTest do
  use ExUnit.Case, async: true
  import ParamsNormalizer

  describe "validate_and_normalize_params/2 when params are valid" do
    setup [:basic_params, :basic_process]

    test "returns ok", %{params: params, process: process} do
      validated_and_normalized_params = validate_and_normalize_params(params, process)
      assert {:ok, %{}} = validated_and_normalized_params
    end

    test "applies the process function to each value", %{params: params, process: process} do
      {:ok, result} = validate_and_normalize_params(params, process)
      assert result["data"]["attributes"]["id"] == 3
    end

    test "returns the same structure as the passed in params", %{params: params, process: process} do
      {:ok, result} = validate_and_normalize_params(params, process)
      assert result == %{
        "data" => %{
          "attributes" => %{
            "id" => 3
          }
        }
      }
    end
  end

  describe "validate_and_normalize_params/2 when params are invalid" do
    setup [:invalid_params, :basic_process]

    test "returns a list of errors", %{params: params, process: process} do
      assert {:error, :invalid_params, %{"data.attributes.id" => "can't cast value to integer"}} ==
        validate_and_normalize_params(params, process)
    end
  end

  describe "validate_and_normalize_params/2 when fields to process is an error" do
    setup [:basic_params]

    test "returns a list of errors", %{params: params} do
      assert {:error, :invalid_params, %{"data.attributes.id" => "missing or invalid"}} ==
        validate_and_normalize_params(params, {:error, [["data", "attributes", "id"]]})
    end
  end


  describe "string_to_integer/1 when input is an int" do
    test "returns the passed in int" do
      assert {:ok, 3} == string_to_integer(3)
    end
  end

  describe "string_to_integer/1 when input is a valid integer string" do
    test "returns the string cast to an integer" do
      assert {:ok, 3} == string_to_integer("3")
    end
  end

  describe "string_to_integer/1 when input is an invalid string" do
    test "returns an errror" do
      assert {:error, "can't cast value to integer"} == string_to_integer("test")
    end
  end

  defp basic_params(_context) do
    params = %{
      "data" => %{
        "attributes" => %{
          "id" => "3"
        }
      }
    }
    [params: params]
  end

  defp invalid_params(_context) do
    params = %{
      "data" => %{
        "attributes" => %{
          "id" => ["3"]
        }
      }
    }
    [params: params]
  end

  defp basic_process(_context) do
    process = [
      %{path: ["data", "attributes", "id"], process: &string_to_integer/1}
    ]
    [process: process]
  end
end

# ParamsNormalizer

Provides a mechanism for normalizing params in phoenix controllers.

Example usage:

```elixir
    import ParamsNormalizer

    action_fallback MyActionFallbackController

    def index(conn, params)
      process_params_func = fn ->
        process = [
          %{path: ["data", "attributes", "id"], process: &string_to_integer/1}
        ]

        validate_and_normalize_params(params, process)
      end

      execute_func = fn(id) ->
        data = MyModule.call(id)

        render(conn, MyView, "index.json", %{data: data})
      end

      with {:ok, %{"data" => %{"attributes" => %{"id" => id}}} <- process_params_func.(params),
      do: execute_func.(id)
    end
```

Here we are using a consistent pattern in our controllers. We have one function, `process_params_func` and an `execute_func`.

The process_params_func makes a call to the `validate_and_normalize_params`, passing it a list of maps, containing a path to the params
to be validated and a function to validate and normalize.

This function needs to return an `{:ok, value}` which will be put back into the params in the same place it was passed in (see details for more information)

If any of the validations return an error, the `with` function won't execute and the `action_fallback` call function will be called.

In your `action_fallback` plug you will need to implement a function which  will handle a `def call(conn, {:error, :invalid_params, errors}`

### Rationale

The controller may get slightly larger here with the actions, however it provides a consistent format that becomes easier to read.

Basically, when looking at an action you can see at the top what and how the params are going to be processed as well as what action
will be executed if the params are successfully validated.

### Details

  Below shows how the `validate_and_normalize_params` function works.

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

## Installation

```elixir
def deps do
  [
    {:params_normalizer, github: "myxplor/params-normalizer.git"}
  ]
end
```

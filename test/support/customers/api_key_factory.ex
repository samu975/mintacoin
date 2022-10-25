defmodule Mintacoin.ApiKeyFactory do
  @moduledoc """
  Allow the creation of Apikey while testing.
  """

  alias Ecto.UUID
  alias Mintacoin.ApiKey

  defmacro __using__(_opts) do
    quote do
      @spec api_key_factory(attrs :: map()) :: ApiKey.t()
      def api_key_factory(attrs) do
        default_api_key =
          "SFMyNTY.g2gDdAAAAAFkAAphY2NvdW50X2lkbQAAACQ4ZDkzYTkyOC05ZjM5LTQ4ZWMtOGIyNy0xZTdmN2NiZmE3NGVuBgDZmfYPhAFiAFxJAA.SRlUgdy7igREKsUdMM3POiqKZMr5bke9xAq8qa_ad_A"

        default_encrypted_api_key =
          "q62e5ySEDrlclOdrEi+7gmtp7qRNCDkCEHFFmjpsm0ATNPSXzexcrd3NEyDPI2TbnRuRV1nqXt51gofMNd5r2Yzbnul33HZjy11dtJoT7M7gl6VtOY597mT4bs5v2DgrgTEjo3omub/GfasqAVHHBGBDjycKrKMc2/vEoY0X0CpXt+muWZLa1zR58PxH+NfZa0b52j+dKB2Hb4zpzkbw5ghmnjUC9b265UZDydS0wxQ"

        name = Map.get(attrs, :name, "Customer")
        account = Map.get(attrs, :account, insert(:account))
        api_key = Map.get(attrs, :api_key, default_api_key)
        encrypted_api_key = Map.get(attrs, :encrypted_api_key, default_encrypted_api_key)

        %ApiKey{
          id: UUID.generate(),
          name: name,
          account: account,
          api_key: api_key,
          encrypted_api_key: encrypted_api_key
        }
        |> merge_attributes(attrs)
        |> evaluate_lazy_attributes()
      end
    end
  end
end

defmodule Chronic.UnknownFormatTest do
  use ExUnit.Case, async: true

  test "returns an error if format is unknown" do
    assert {:error, :unknown_format} = Chronic.parse("definitely not a known format, no siree")
  end
end

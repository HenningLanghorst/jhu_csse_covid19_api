defmodule Covid19ApiWeb.DateOperationsTest do
  use ExUnit.Case
  alias Covid19ApiWeb.DateOperations

  setup do
    IO.puts("This will run before each test that uses this case")
  end

  test "should return :ok and valid date with format m/d/yy" do
    assert DateOperations.parse_date("5/12/20") === {:ok, ~D[2020-05-12]}
  end

  test "should return :error and :invalid_date for date with format m/d/yyyy" do
    assert DateOperations.parse_date("5/12/2020") === {:error, :invalid_date}
  end

  test "should return :error and :invalid_date for German date with format dd.mm.yyyy" do
    assert DateOperations.parse_date("12.05.2020") === {:error, :invalid_date}
  end
end

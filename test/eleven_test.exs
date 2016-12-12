defmodule ElevenTest do
  use ExUnit.Case
  doctest Eleven
  import Eleven

  test "danger" do
    assert danger?([1,2,3,5])
    refute danger?([1,2,3,4])
    assert danger?([1,3,4])
    refute danger?([2,4])
    refute danger?([])
  end
end

require "minitest/autorun"
require_relative "../lib/adder"

class AdderTest < Minitest::Test
  def test_add
    assert_equal 3, Adder.add(1, 2)
  end
end

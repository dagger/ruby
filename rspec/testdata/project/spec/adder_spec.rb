require_relative "../lib/adder"

RSpec.describe Adder do
  it "adds two numbers" do
    expect(Adder.add(1, 2)).to eq(3)
  end
end

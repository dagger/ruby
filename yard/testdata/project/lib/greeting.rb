# Greets people by name.
module Greeting
  # Builds a greeting.
  #
  # @param name [String] who to greet
  # @return [String] the greeting
  def self.hello(name)
    "Hello, #{name}!"
  end
end

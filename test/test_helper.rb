require "minitest/autorun"

# To see full test names when running tests:
#
# require "minitest/reporters"
# Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

module Minitest::Assertions
  def assert_invalid_transition
    assert_raises AASM::InvalidTransition do
      yield
    end
  end
end

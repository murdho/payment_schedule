require 'test_helper'

class PaymentSchedule::CommonTest < Minitest::Test
  TestClass = Class.new do
    include PaymentSchedule::Common

    INPUT = {}
  end

  def test_error_constant_is_defined
    assert TestClass.const_defined?(:Error)
  end
end

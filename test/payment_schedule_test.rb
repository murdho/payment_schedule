require 'test_helper'

class PaymentScheduleTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::PaymentSchedule::VERSION
  end
end

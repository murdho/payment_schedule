require 'test_helper'
require 'payment_schedule/output'

OutputTestSchedule = PaymentSchedule.new do
  helper(:first_row_number) { 0 }
  helper(:last_row_number)  { 10 }

  component(:ten_minus_n) do
    default { |n| 10 - n }
  end

  component(:n_plus_n) do
    default { |n| n + n }
  end
end

class PaymentSchedule::OutputTest < Minitest::Test
  attr_reader :schedule

  def setup
    @schedule = OutputTestSchedule.new
  end

  def test_string_output
    actual_output   = PaymentSchedule::Output.to_s(@schedule)
    expected_output = <<~EOS.strip
      +----+-------------+----------+
      |     OutputTestSchedule      |
      +----+-------------+----------+
      | No | Ten minus n | N plus n |
      +----+-------------+----------+
      | 0  | 10          | 0        |
      | 1  | 9           | 2        |
      | 2  | 8           | 4        |
      | 3  | 7           | 6        |
      | 4  | 6           | 8        |
      | 5  | 5           | 10       |
      | 6  | 4           | 12       |
      | 7  | 3           | 14       |
      | 8  | 2           | 16       |
      | 9  | 1           | 18       |
      | 10 | 0           | 20       |
      +----+-------------+----------+
    EOS

    assert_equal(actual_output, expected_output)
  end
end

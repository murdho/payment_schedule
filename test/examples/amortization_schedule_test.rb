require 'test_helper'
require 'amortization_schedule'

class AmortizationScheduleTest < Minitest::Test
  attr_reader :schedule

  parallelize_me!
  make_my_diffs_pretty!

  def input
    {
      loan_amount:        15250,
      loan_term:          18,
      interest_rate_year: 0.12,
      start_of_schedule:  Date.new(2017, 1, 31),
      additional_fees:    3
    }
  end

  def setup
    @schedule = AmortizationSchedule.new(input)
  end

  def assert_correct_values(row_no, **values)
    values.each do |attr_name, expected_value|
      calculated_value = schedule[attr_name, row_no]

      assert_equal calculated_value, expected_value, "#{attr_name} is invalid"
    end
  end

  def test_algorithm_produces_correct_first_row
    first_row_values = {
      date:            Date.new(2017, 1, 31),
      balance:         15250.00.to_d,
      principal:       0.00.to_d,
      interest:        0.00.to_d,
      additional_fees: 0.00.to_d,
      monthly_payment: 0.00.to_d
    }

    assert_correct_values(0, first_row_values)
  end

  def test_algorithm_produces_correct_second_row
    second_row_values = {
      date:            Date.new(2017, 2, 28),
      balance:         15250.00.to_d,
      principal:       780.94.to_d,
      interest:        144.70.to_d,
      additional_fees: 3.00.to_d,
      monthly_payment: 928.64.to_d
    }

    assert_correct_values(1, second_row_values)
  end

  def test_algorithm_produces_correct_last_row
    last_row_values = {
      date:            Date.new(2018, 7, 31),
      balance:         916.84.to_d,
      principal:       916.84.to_d,
      interest:        8.70.to_d,
      additional_fees: 3.00.to_d,
      monthly_payment: 928.54.to_d
    }

    assert_correct_values(input[:loan_term], last_row_values)
  end
end















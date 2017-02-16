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

  def initial_memory
    {
      helpers: {},
      schedules: {}
    }
  end
  alias_method :initial_instructions, :initial_memory

  def setup
    @schedule = AmortizationSchedule.new(input)
  end

  def test_input_is_stored
    assert_equal schedule.input, input
  end

  def test_memory_and_instructions_are_initialized
    assert_equal schedule.memory.keys, initial_memory.keys
    assert_equal schedule.instructions.keys, initial_instructions.keys
  end

  def test_input_validation
    assert_raises(AmortizationSchedule::Error) do
      AmortizationSchedule.new
    end
  end

  def test_gets_value_from_input
    key = input.keys.sample

    assert_equal schedule.get(key), input[key]
  end

  def test_gets_constant_helper_value
    value = :xyz
    schedule.define_helper(:test, value)

    assert_equal schedule.get(:test), value
  end

  def test_gets_calculated_helper_value
    value = :abc
    schedule.define_helper(:test) { value }

    assert_equal schedule.get(:test), value
  end

  def test_memoization_of_get
    value1, value2 = :abc, :xyz

    schedule.define_helper(:test) { value1 }
    assert_equal schedule.get(:test), value1

    schedule.define_helper(:test) { value2 }
    assert_equal schedule.get(:test), value1
  end

  def assert_correct_values(schedule_name, row_no, **values)
    values.each do |attr_name, expected_value|
      calculated_value = schedule.schedule_get(schedule_name, attr_name, row_no)

      assert_equal calculated_value, expected_value, "#{attr_name} is invalid"
    end
  end

  def test_algorithm_produces_correct_first_row
    last_row_values = {
      date:            Date.new(2017, 1, 31),
      balance:         15250.00.to_d,
      principal:       0.00.to_d,
      interest:        0.00.to_d,
      additional_fees: 0.00.to_d,
      monthly_payment: 0.00.to_d
    }

    assert_correct_values(:amortization, 0, last_row_values)
  end

  def test_algorithm_produces_correct_second_row
    last_row_values = {
      date:            Date.new(2017, 2, 28),
      balance:         15250.00.to_d,
      principal:       780.94.to_d,
      interest:        144.70.to_d,
      additional_fees: 3.00.to_d,
      monthly_payment: 928.64.to_d
    }

    assert_correct_values(:amortization, 1, last_row_values)
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

    assert_correct_values(:amortization, input[:loan_term], last_row_values)
  end
end















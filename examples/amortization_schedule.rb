require 'bigdecimal'
require 'bigdecimal/util'
require 'payment_schedule'
require 'terminal-table'

# TODO LIST
# 1. implement schedule according to Excel payment-schedule-example.xlsx
# 1.1 add comments
# 2. add tests
# 3. refactor for extracting common methods to separate module

BigDecimal.class_eval do
  alias_method :original_to_s, :to_s

  def to_s(s = 'F')
    original_to_s(s)
  end
end

# s = AmortizationSchedule.new(
#   loan_amount:        15250,
#   loan_term:          18,
#   interest_rate_year: 0.12,
#   start_of_schedule:  Date.new(2017, 1, 31),
#   additional_fees:    3
# )
#
# s.print_results

class AmortizationSchedule
  Error = Class.new(StandardError)

  INPUT = %i(
    loan_amount
    loan_term
    interest_rate_year
    start_of_schedule
    additional_fees
  )

  OUTPUT = %i(
    monthly_payment
    last_payment_date
    last_payment_amount
    total_interest_paid
    total_amount_paid
  )

  HELPERS = %i(
    interest_rate_month
    monthly_payment_without_fees
  )

  SCHEDULES = %i(
    amortization
  )

  attr_accessor :input, :memory, :instructions

  def initialize(**input)
    self.input = input

    self.memory = {
      helpers:   {},
      schedules: {}
    }

    self.instructions = {
      helpers:   {},
      schedules: {}
    }

    validate_input!
    # validate_output!

    register_instructions
  end

  def helpers
    instructions[:helpers] ||= {}
  end

  def schedules
    instructions[:schedules] ||= {}
  end

  def print_results
    puts "\nINPUTS:"
    rows = []
    rows << INPUT
    rows << :separator
    rows << INPUT.map { |x| get(x) }

    puts Terminal::Table.new(rows: rows)

    schedules.each do |name, _|
      puts "\n#{name.to_s.upcase.gsub('_', ' ')} SCHEDULE:"
      print_schedule(name)
    end

    puts "\nOUTPUTS:"
    rows = []
    rows << OUTPUT
    rows << :separator
    rows << OUTPUT.map { |x| get(x) }

    puts Terminal::Table.new(rows: rows)
  end

  def print_schedule(schedule_name)
    first_row_no  = 0
    last_row_no   = get(:loan_term)
    schedule = schedules[schedule_name]

    keys = schedule.keys
    width = keys.max { |k| k.length }.length + 2

    rows = []

    heading = ['row_no', keys].flatten
    rows << heading
    rows << :separator

    (first_row_no..last_row_no).each do |row_no|
      row = [row_no]

      row << keys.map { |attr_name| schedule_get(schedule_name, attr_name, row_no) }
      rows << row.flatten
    end

    puts Terminal::Table.new(rows: rows)
  end

  def full_schedule
    first_row_no  = 0
    last_row_no   = get(:loan_term)
    schedule_name = :amortization

    (first_row_no..last_row_no).each do |row_no|
      schedules[schedule_name].each do |attr, _|
        schedule_get(schedule_name, attr, row_no)
      end
    end
  end

  def range_key_hash(regular_hash)
    supercharged_hash = regular_hash.dup

    supercharged_hash.default_proc = lambda do |hash, key|
      hash.find { |key2, _| key2 === key }&.last
    end

    supercharged_hash
  end

  def get(input_or_helper_key)
    memoized_value = memory.dig(:helpers, input_or_helper_key)
    return memoized_value if memoized_value

    instruction_or_constant = helpers[input_or_helper_key]

    helper_value = begin
      if instruction_or_constant.respond_to?(:call)
        instruction_or_constant.call
      else
        instruction_or_constant
      end
    end

    if helper_value
      memory[:helpers][input_or_helper_key] = helper_value
    else
      input[input_or_helper_key]
    end
  end

  def schedule_get(schedule_name, attr_name, row_no)
    memoized_value = memory.dig(:schedules, schedule_name, attr_name, row_no)
    return memoized_value if memoized_value

    instruction_or_constant = begin
      schedules.dig(schedule_name, attr_name, row_no) ||
        schedules.dig(schedule_name, attr_name, :default)
    end

    value = begin
      if instruction_or_constant.respond_to?(:call)
        instruction_or_constant.call(row_no)
      else
        instruction_or_constant
      end
    end

    memory[:schedules][schedule_name] ||= {}
    memory[:schedules][schedule_name][attr_name] ||= {}
    memory[:schedules][schedule_name][attr_name][row_no] = value
  end

  def define_helper(name, value = nil, &algorithm)
    instructions[:helpers][name] = value || algorithm
  end

  def register_instructions
    schedules[:amortization] = amortization_instructions

    validate_instructions!

    define_helper(:interest_rate_month) do
      (1 + get(:interest_rate_year).to_d) ** (1.to_d / 12) - 1
    end

    define_helper(:monthly_payment_without_fees) do
      tank = (get(:loan_amount).to_d * get(:interest_rate_month)) / (1 - (1 + get(:interest_rate_month)) ** (-get(:loan_term)))
      tank.round(2)
    end

    define_helper(:monthly_payment) do
      get(:monthly_payment_without_fees) + get(:additional_fees)
    end

    define_helper(:last_payment_date) do
      amortization(:date, get(:loan_term))
    end

    define_helper(:last_payment_amount) do
      amortization(:monthly_payment, get(:loan_term))
    end

    define_helper(:total_interest_paid) do
      first_row_no  = 0
      last_row_no   = get(:loan_term)

      (first_row_no..last_row_no).sum do |row_no|
        amortization(:interest, row_no)
      end
    end

    define_helper(:total_amount_paid) do
      first_row_no  = 0
      last_row_no   = get(:loan_term)

      (first_row_no..last_row_no).sum do |row_no|
        amortization(:monthly_payment, row_no)
      end
    end

    schedules.each do |schedule_name, _|
      define_singleton_method(schedule_name) do |attr_name, row_no|
        schedule_get(schedule_name, attr_name, row_no)
      end
    end
  end

  def validate_input!
    INPUT.each do |input_key|
      next if input.key?(input_key)

      fail Error, "Missing required key '#{input_key}'"
    end
  end

  def validate_output!
    OUTPUT.each do |output_key|
      next if instruction_present?(output_key)

      fail Error, "Missing instructions for output key '#{output_key}'"
    end
  end

  def validate_instructions!
    if instructions[:schedules].nil? || instructions[:schedules].empty?
      fail Error, "Please provide at least 1 instruction for a schedule"
    end
  end

  def instruction_present?(instr_key)
    helpers.key?(instr_key)
  end

  def amortization_instructions
    {
      date: {
        0 => proc do
          get(:start_of_schedule)
        end,

        default: proc do |n|
          amortization(:date, 0).next_month(n)
        end
      },

      balance: range_key_hash(
        (0..1) => proc do
          get(:loan_amount)
        end,

        default: proc do |n|
          amortization(:balance, n - 1) - amortization(:principal, n - 1)
        end
      ),

      principal: {
        0 => 0,

        1 => proc do
          get(:monthly_payment_without_fees) - amortization(:interest, 1)
        end,

        default: proc do |n|
          [
            amortization(:balance, n),
            get(:monthly_payment_without_fees) - amortization(:interest, n)
          ].min
        end
      },

      interest: {
        0 => 0,

        default: proc do |n|
          (
            get(:interest_rate_month) * amortization(:balance, n)
          ).round(2)
        end
      },

      additional_fees: {
        0 => 0,

        default: proc do
          get(:additional_fees)
        end
      },

      monthly_payment: {
        default: proc do |n|
          [
            amortization(:principal, n),
            amortization(:interest, n),
            amortization(:additional_fees, n)
          ].sum.round(2)
        end
      }
    }
  end
end

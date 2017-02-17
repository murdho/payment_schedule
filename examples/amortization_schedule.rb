require 'payment_schedule'
require 'terminal-table'

# TODO LIST
# 1. implement schedule according to Excel payment-schedule-example.xlsx
# 1.1 add comments
# 2. add tests
# 3. refactor for extracting common methods to separate module

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
  include PaymentSchedule::Common

  INPUT = %i(
    loan_amount
    loan_term
    interest_rate_year
    start_of_schedule
    additional_fees
  )

  HELPERS = %i(
    interest_rate_month
    monthly_payment_without_fees
  )

  # Util::Output
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

  # Util::Output
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

  def register_instructions
    schedules[:amortization] = amortization_instructions

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

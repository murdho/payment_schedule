require 'payment_schedule'

AmortizationSchedule = PaymentSchedule.new do
  # ------------------------------------------------------------------------
  # INPUTS

  require_input(
    :loan_amount,
    :loan_term,
    :interest_rate_year,
    :start_of_schedule,
    :additional_fees
  )

  # ------------------------------------------------------------------------
  # HELPERS

  helper(:first_row_number) do
    0
  end

  helper(:last_row_number) do
    self[:loan_term]
  end

  helper(:interest_rate_month) do
    (1 + self[:interest_rate_year].to_d) ** (1 / 12.to_d) - 1
  end

  helper(:monthly_payment_without_fees) do
    divisor  = 1 - (1 + self[:interest_rate_month]) ** -self[:loan_term]
    quotient = self[:loan_amount] * self[:interest_rate_month] / divisor
    quotient.round(2)
  end

  helper(:monthly_payment) do
    self[:monthly_payment_without_fees] + self[:additional_fees]
  end

  helper(:last_payment_date) do
    self[:date, self[:loan_term]]
  end

  helper(:last_payment_amount) do
    self[:monthly_payment, self[:loan_term]]
  end

  helper(:total_interest_paid) do
    sum(:interest)
  end

  helper(:total_amount_paid) do
    sum(:monthly_payment)
  end

  # ------------------------------------------------------------------------
  # COMPONENTS

  component(:date) do
    row(0)  { self[:start_of_schedule] }
    default { |n| self[:date, 0].next_month(n) }
  end

  component(:balance) do
    rows(0..1) { self[:loan_amount] }
    default    { |n| self[:balance, n - 1] - self[:principal, n - 1] }
  end

  component(:principal) do
    row(0) { 0 }
    row(1) { self[:monthly_payment_without_fees] - self[:interest, 1] }
    default do |n|
      [
        self[:balance, n],
        self[:monthly_payment_without_fees] - self[:interest, n]
      ].min
    end
  end

  component(:interest) do
    row(0)  { 0 }
    default { |n| (self[:interest_rate_month] * self[:balance, n]).round(2) }
  end

  component(:additional_fees) do
    row(0)  { 0 }
    default { self[:additional_fees] }
  end

  component(:monthly_payment) do
    default do |n|
      [
        self[:principal, n],
        self[:interest, n],
        self[:additional_fees, n]
      ].sum.round(2)
    end
  end
end

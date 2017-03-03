# PaymentSchedule

[![Build Status](https://travis-ci.org/murdho/payment_schedule.svg?branch=master)](https://travis-ci.org/murdho/payment_schedule)
[![Code Climate](https://lima.codeclimate.com/github/murdho/payment_schedule/badges/gpa.svg)](https://lima.codeclimate.com/github/murdho/payment_schedule)
[![Test Coverage](https://lima.codeclimate.com/github/murdho/payment_schedule/badges/coverage.svg)](https://lima.codeclimate.com/github/murdho/payment_schedule/coverage)

PaymentSchedule is a Ruby gem for describing and calculating payment schedules. Its goal is to make implementation and modification of payment schedule algorithms fast and easy to understand.

Requires Ruby 2.4.0 or higher.



## Introduction

#### Easy to use

Simple to keep the algorithm similar to payment schedule's tabular nature. This enables faster changes in the code when the specification changes. At the same time code is clear and readable, even for a person who hasn't got much experience with such algorithms.



#### Fast

It has good memory and is very lazy — that's why it calculates as little as needed and is very fast.



## Example

Take a look at the example, which demostrates the simplicity of the gem.



#### Example specification (spreadsheet)

Algorithm implemented using a spreadsheet software: [amortization_schedule.xlsx](examples/amortization_schedule.xlsx)

Screenshot:

<p align="center">
  <img src="media/screenshot-payment-schedule-example-xlsx.png" alt="Screenshot of payment schedule example spreadsheet" />
</p>



#### Example implementation in Ruby

Algorithm implementation in Ruby, based on the spreadsheet: [amortization_schedule.rb](examples/amortization_schedule.rb)

Screenshot:

<p align="center">
  <img src="media/screenshot-payment-schedule-example-term.png" alt="Screenshot of payment schedule example terminal output" />
</p>


## Getting Started

1. Add this line to your application's Gemfile:

   ```ruby
   gem 'payment_schedule'
   ```

2. In project directory, execute:

   ```shell
   bundle
   ```

3. Create a class which describes the algorithm:

   ```ruby
   # Description of My Awesome Payment Schedule algorithm.
   # References spreadsheet examples/amortization_schedule.xlsx

   MyAwesomeSchedule = PaymentSchedule.new do
     require_input(
       :loan_amount,        # Cell: C5
       :loan_term,          # Cell: C6
       :interest_rate_year  # Cell: C7
     )

     # Helper required by algorithm for output and summation
     helper(:first_row_number) do
       0
     end

     # Helper required by algorithm for output and summation
     helper(:last_row_number) do
       self[:loan_term]
     end

     # Cell: C8
     helper(:interest_rate_month) do
       (1 + self[:interest_rate_year].to_d) ** (1 / 12.to_d) - 1
     end

     # Column: G
     # Note: modified for simplified example
     component(:balance) do
       # Cells: G6-G7
       rows(0..1) { self[:loan_amount] }

       default do |n|
         self[:balance, n - 1] - n * 5
       end
     end

     # Column: I
     component(:interest) do
       # Cell: I6
       row(0) { 0 }

       default do |n|
         (self[:interest_rate_month] * self[:balance, n]).round(2)
       end
     end
   end
   ```

4. Try it out in REPL:

   ```ruby
   schedule = MyAwesomeSchedule.new(
     loan_amount:        1000,
     loan_term:          12,
     interest_rate_year: 0.1
   )

   schedule[:balance, 12]
   # => 615

   schedule[:interest_rate_month]
   # => 0.00797414042890374

   puts schedule
   +----+---------+----------+
   |    MyAwesomeSchedule    |
   +----+---------+----------+
   | No | Balance | Interest |
   +----+---------+----------+
   | 0  | 1000    | 0        |
   | 1  | 1000    | 7.97     |
   | 2  | 990     | 7.89     |
   | 3  | 975     | 7.77     |
   | 4  | 955     | 7.62     |
   | 5  | 930     | 7.42     |
   | 6  | 900     | 7.18     |
   | 7  | 865     | 6.9      |
   | 8  | 825     | 6.58     |
   | 9  | 780     | 6.22     |
   | 10 | 730     | 5.82     |
   | 11 | 675     | 5.38     |
   | 12 | 615     | 4.9      |
   +----+---------+----------+
   # => nil
   ```

5. Plug it in to your app

6. Share it with customers

7. Profit! :sunglasses:



## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Murdho/payment_schedule. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Wishlist

Things that would make it even nicer to use.
* Add proper documentation (preferably TomDoc) for lowering the barriers of entry
* Replace `MyClassName = PaymentSchedule.new(&block)` with `class MyClassName < PaymentSchedule::Schedule` (or similar) to enable inheritance for schedule definitions. Definitely needs modifications to instruction finding as well
* Algorithm for generating the schedule Ruby code automatically based on spreadsheet file
* Add more commented examples for demonstrating flexibility, readbility and power!

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


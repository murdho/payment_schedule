require 'payment_schedule/core_ext/big_decimal'
require 'payment_schedule/instruction'
require 'payment_schedule/schedule'
require 'payment_schedule/version'

module PaymentSchedule
  def self.new(const_name = nil, &block)
    instruction = Instruction.new
    instruction.instance_eval(&block)

    schedule_class             = Class.new(Schedule)
    schedule_class.instruction = instruction

    Object.const_set(const_name.to_s, schedule_class) if const_name

    schedule_class
  end
end

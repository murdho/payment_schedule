module PaymentSchedule
  class Schedule
    class << self
      attr_accessor :instruction
    end

    attr_accessor :input

    # TODO: input validation

    def initialize(**input)
      self.input = input
    end

    def [](*args)
      input[args.first] || self.class.instruction[*args]
    end
  end
end

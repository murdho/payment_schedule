module PaymentSchedule
  class Schedule
    Error = Class.new(StandardError)

    class << self
      attr_accessor :instruction
    end

    attr_accessor :input

    # TODO: input validation

    def initialize(**input)
      self.input = input

      validate_input!
    end

    def [](*args)
      input[args.first] || instruction[*args]
    end

    private

    def validate_input!
      missing_keys = instruction.required_input.reject do |required_key|
        input.key?(required_key)
      end

      return if missing_keys.empty?

      raise Error, "Missing required input key(s) :#{missing_keys.join(', :')}"
    end

    def instruction
      self.class.instruction
    end
  end
end

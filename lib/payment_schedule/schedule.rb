module PaymentSchedule
  class Schedule
    Error = Class.new(StandardError)

    class << self
      attr_accessor :instruction
    end

    attr_accessor :input
    attr_accessor :helper_memory
    attr_accessor :component_memory

    def initialize(**input)
      self.input            = input
      self.helper_memory    = {}
      self.component_memory = {}

      validate_input!
    end

    def [](name, row_no = nil)
      if row_no
        component_get(name, row_no)
      else
        input[name] || helper_get(name)
      end
    end

    private

    def instruction
      self.class.instruction
    end

    def components
      instruction.components
    end

    def helpers
      instruction.helpers
    end

    def component_get(name, row_no)
      return unless components.key?(name)

      memory_key     = [name, row_no].join(':')
      memoized_value = component_memory[memory_key]
      return memoized_value if memoized_value

      component_memory[memory_key] = instance_exec(
        row_no,
        &components[name][row_no]
      )
    end

    def helper_get(name)
      return unless helpers.key?(name)

      memoized_value = helper_memory[name]
      return memoized_value if memoized_value

      helper_memory[name] = instance_exec(&helpers[name])
    end

    def validate_input!
      missing_keys = instruction.required_input.reject do |required_key|
        input.key?(required_key)
      end

      return if missing_keys.empty?

      raise Error, "Missing required input key(s) :#{missing_keys.join(', :')}"
    end
  end
end

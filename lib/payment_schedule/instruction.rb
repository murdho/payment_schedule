require 'payment_schedule/component'

module PaymentSchedule
  class Instruction
    attr_accessor :required_input
    attr_accessor :helpers
    attr_accessor :components
    attr_accessor :helper_memory
    attr_accessor :component_memory

    def initialize
      self.required_input   = []
      self.helpers          = {}
      self.components       = {}
      self.helper_memory    = {}
      self.component_memory = {}
    end

    def [](name, row_no = nil)
      row_no ? component_get(name, row_no) : helper_get(name)
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

    def require_input(*keys)
      self.required_input = keys
    end

    def helper(name, &definition)
      helpers[name] = definition
    end

    def component(name, &definition)
      component = Component.new(name)
      component.instance_eval(&definition)
      components[name] = component
    end
  end
end

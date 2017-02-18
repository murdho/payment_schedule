require 'payment_schedule/component'

module PaymentSchedule
  class Instruction
    attr_accessor :required_input
    attr_accessor :helpers
    attr_accessor :components

    # TODO: memoization

    def initialize
      self.required_input = []
      self.helpers        = {}
      self.components     = {}
    end

    def [](name, row_no = nil)
      row_no ? component_get(name, row_no) : helper_get(name)
    end

    def component_get(name, row_no)
      instance_exec(row_no, &components[name][row_no]) if components.key?(name)
    end

    def helper_get(name)
      instance_exec(&helpers[name]) if helpers.key?(name)
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

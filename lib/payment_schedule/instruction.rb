require 'payment_schedule/component'

module PaymentSchedule
  class Instruction
    attr_accessor :required_input
    attr_accessor :helpers
    attr_accessor :components

    def initialize
      self.required_input = []
      self.helpers        = {}
      self.components     = {}
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

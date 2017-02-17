module PaymentSchedule
  module Common
    Error = Class.new(StandardError)

    attr_accessor :input, :memory, :instructions

    def initialize(**input)
      self.input = input

      self.memory = {
        helpers:   {},
        schedules: {}
      }

      self.instructions = {
        helpers:   {},
        schedules: {}
      }

      validate_input!
      register_instructions
    end

    def helpers
      instructions[:helpers] ||= {}
    end

    def schedules
      instructions[:schedules] ||= {}
    end

    def full_schedule
      first_row_no  = 0
      last_row_no   = get(:loan_term)
      schedule_name = :amortization

      (first_row_no..last_row_no).each do |row_no|
        schedules[schedule_name].each do |attr, _|
          schedule_get(schedule_name, attr, row_no)
        end
      end
    end

    # Util
    def range_key_hash(regular_hash)
      supercharged_hash = regular_hash.dup

      supercharged_hash.default_proc = lambda do |hash, key|
        hash.find { |key2, _| key2 === key }&.last
      end

      supercharged_hash
    end

    def get(input_or_helper_key)
      memoized_value = memory.dig(:helpers, input_or_helper_key)
      return memoized_value if memoized_value

      instruction_or_constant = helpers[input_or_helper_key]

      helper_value = begin
        if instruction_or_constant.respond_to?(:call)
          instruction_or_constant.call
        else
          instruction_or_constant
        end
      end

      if helper_value
        memory[:helpers][input_or_helper_key] = helper_value
      else
        input[input_or_helper_key]
      end
    end

    def schedule_get(schedule_name, attr_name, row_no)
      memoized_value = memory.dig(:schedules, schedule_name, attr_name, row_no)
      return memoized_value if memoized_value

      instruction_or_constant = begin
        schedules.dig(schedule_name, attr_name, row_no) ||
          schedules.dig(schedule_name, attr_name, :default)
      end

      value = begin
        if instruction_or_constant.respond_to?(:call)
          instruction_or_constant.call(row_no)
        else
          instruction_or_constant
        end
      end

      memory[:schedules][schedule_name] ||= {}
      memory[:schedules][schedule_name][attr_name] ||= {}
      memory[:schedules][schedule_name][attr_name][row_no] = value
    end

    def define_helper(name, value = nil, &algorithm)
      instructions[:helpers][name] = value || algorithm
    end

    def validate_input!
      singleton_class::INPUT.each do |input_key|
        next if input.key?(input_key)

        fail Error, "Missing required key '#{input_key}'"
      end
    end
  end
end

module PaymentSchedule
  class Component
    attr_accessor :name, :row_definitions

    def initialize(name)
      self.name = name
      self.row_definitions = {}
    end

    def [](row_no)
      row_definitions[row_no] || row_definitions[:default]
    end

    def row(no, &definition)
      row_definitions[no] = definition
    end

    def rows(no_range, &definition)
      no_range.each { |no| row(no, &definition) }
    end

    def default(&definition)
      row_definitions[:default] = definition
    end
  end
end

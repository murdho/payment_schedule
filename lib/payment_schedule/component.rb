module PaymentSchedule
  class Component
    attr_accessor :name, :rows

    def initialize(name)
      self.name = name
      self.rows = {}
    end

    def [](row_no)
      rows[row_no] || rows[:default]
    end

    def row(no, &definition)
      rows[no] = definition
    end

    def default(&definition)
      rows[:default] = definition
    end
  end
end

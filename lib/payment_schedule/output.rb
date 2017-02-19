require 'terminal-table'

module PaymentSchedule
  class Output
    class << self
      def to_s(schedule)
        table = Terminal::Table.new(title: schedule.class) do |t|
          t << heading(schedule)
          t << :separator

          schedule.row_numbers.each do |row_no|
            t << row_contents(schedule, row_no)
          end
        end

        table.to_s
      end

      private

      def heading(schedule)
        names = schedule.component_names.map { |name| name.to_s.capitalize }
        ['No', names].flatten
      end

      def row_contents(schedule, row_no)
        values = schedule.component_names.map { |name| schedule[name, row_no] }
        [row_no, values].flatten
      end
    end
  end
end

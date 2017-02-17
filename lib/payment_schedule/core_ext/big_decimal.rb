require 'bigdecimal'
require 'bigdecimal/util'

module BigDecimalDefaultFormat
  def to_s(s = 'F')
    super(s)
  end
end

BigDecimal.prepend(BigDecimalDefaultFormat)

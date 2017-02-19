require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../examples', __FILE__)
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'payment_schedule'

require 'minitest/autorun'
require 'minitest/hell'

class Minitest::Test
  make_my_diffs_pretty!
end

require "minitest/reporters"
Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new

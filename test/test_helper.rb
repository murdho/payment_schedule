require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../examples', __FILE__)
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'payment_schedule'

require 'minitest/autorun'
require "minitest/reporters"
Minitest::Reporters.use!

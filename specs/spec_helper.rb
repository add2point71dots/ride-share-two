require 'simplecov'
SimpleCov.start

require 'minitest'
require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

require 'csv'

# Require_relative your lib files here!
# require_relative '../lib/driver.rb'
# require_relative '../lib/rider.rb'
# require_relative '../lib/trip.rb'
require_relative '../lib/ride_share'

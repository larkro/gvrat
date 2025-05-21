require "minitest/autorun"
require "rack/test"
require_relative "app"

class DistanceCalculatorTest < Minitest::Test
  def setup
    @calculator_miles = DistanceCalculator.new(current_progress: 100, units: "miles")
    @calculator_km = DistanceCalculator.new(current_progress: 160.9, units: "km")
  end

  def test_miles_left
    assert_equal 578, @calculator_miles.miles_left
  end

  def test_km_left
    assert_in_delta 930.202, @calculator_km.km_left, 0.001
  end

  def test_days_left
    assert_in_delta 57.8, @calculator_miles.days_left, 0.1
  end

  def test_completion_date
    expected_date = Time.now + (60 * 60 * 24) * 57
    assert_in_delta expected_date.to_i, @calculator_miles.completion_date.to_i, 60
  end
end

class GvratTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Gvrat
  end

  def test_get_root
    get "/"
    assert last_response.ok?
    assert_includes last_response.body, "Environment Variables"
  end

  def test_post_root
    post "/", current_progress: 100, daily_pace: 10, units: "miles"
    assert last_response.ok?
    assert_includes last_response.body, "578"
  end

  def test_get_up
    get "/up"
    assert last_response.ok?
    assert_equal "OK", last_response.body
  end

  def test_get_env
    get "/env"
    assert last_response.ok?
    assert_includes last_response.body, "Environment Variables"
  end
end

require "minitest/autorun"
require "rack/test"
require_relative "../app" # Anpassa till din app-fil

class MetricsEndpointTest < Minitest::Test
  include Rack::Test::Methods

  # Metod för att tillhandahålla din Sinatra-applikation
  def app
    Sinatra::Application
  end

  def test_metrics_endpoint_returns_200
    get "/metrics"
    assert_equal 200, last_response.status
  end

  def test_metrics_endpoint_returns_prometheus_metrics
    get "/metrics"
    assert_includes last_response.body, "# TYPE"
    assert_includes last_response.body, "http_server_requests_seconds_count"
  end
end

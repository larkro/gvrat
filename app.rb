require "sinatra/base"
require "date"

# DistanceCalculator class
class DistanceCalculator
  AVERAGE_DAILY_DISTANCE = 10
  TOTAL_DISTANCE = 672

  def initialize(current_progress:, daily_pace: nil, units:)
    @current_progress = current_progress.to_f
    daily_pace = daily_pace&.to_f
    @units = units
  end

  def miles_left
    TOTAL_DISTANCE - @current_progress
  end

  def km_left
    miles_left * 1.609
  end

  def days_left
    distance_left = (@units == "miles") ? miles_left : km_left
    daily_pace = daily_pace || AVERAGE_DAILY_DISTANCE
    distance_left / daily_pace
  end

  def completion_date
    Time.now + (60 * 60 * 24) * days_left.to_i
  end
end

# Modular Sinatra app
class Gvrat < Sinatra::Base
  configure do
    set :host_authorization, {permitted_hosts: []}
    set :bind, "0.0.0.0"
  end

  get "/" do
    erb :index
  end

  get "/up" do
    status 200
    body "OK"
  end

  get "/env" do
    # Define the env vars you want to display
    env_vars = {
      "GIT_HASH" => ENV["GIT_HASH"],
      "GIT_TAGS" => ENV["GIT_TAGS"],
      "APP_VERSION" => ENV["APP_VERSION"],
      "RAILS_ENV" => ENV["RAILS_ENV"]
    }

    html = <<~HTML
      <h1>Environment Variables</h1>
      <ul>
        #{env_vars.filter_map { |key, value| "<li><strong>#{key}:</strong> #{value}</li>" if value }.join}
      </ul>
    HTML

    status 200
    erb html
  end

  post "/" do
    current_progress = params[:current_progress].to_f
    daily_pace = params[:daily_pace].to_f
    units = params[:units]

    distance_calculator = DistanceCalculator.new(
      current_progress: current_progress,
      daily_pace: daily_pace,
      units: units
    )

    @miles_left = distance_calculator.miles_left
    @km_left = distance_calculator.km_left
    @days_left = distance_calculator.days_left
    @completion_date = distance_calculator.completion_date

    erb :index
  end

  not_found do
    redirect to("/")
  end

  # Start the application if run directly
  run! if app_file == $0
end

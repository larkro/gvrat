require "sinatra"
require "date"

# Calculates distances and estimated completion dates based on given input.
class DistanceCalculator
  AVERAGE_DAILY_DISTANCE = 10
  TOTAL_DISTANCE = 672

  def initialize(args)
    @current_progress = args[:current_progress].to_f
    @daily_pace = args[:daily_pace]&.to_f
    @units = args[:units]
  end

  def miles_left
    TOTAL_DISTANCE - @current_progress
  end

  def km_left
    miles_left * 1.609
  end

  def days_left
    distance_left = (@units == "miles") ? miles_left : km_left
    daily_pace = @daily_pace || AVERAGE_DAILY_DISTANCE
    distance_left / daily_pace
  end

  def completion_date
    Time.now + (60 * 60 * 24) * days_left.to_i
  end
end

# Sinatra app
get "/" do
  erb :index
end

get "/up" do
  status 200
end

post "/" do
  @current_progress = params[:current_progress].to_f
  @daily_pace = params[:daily_pace].to_f
  @units = params[:units]

  distance_calculator = DistanceCalculator.new(
    current_progress: @current_progress,
    daily_pace: @daily_pace,
    units: @units
  )

  @miles_left = distance_calculator.miles_left
  @km_left = distance_calculator.km_left
  @days_left = distance_calculator.days_left
  @completion_date = distance_calculator.completion_date

  erb :index
end

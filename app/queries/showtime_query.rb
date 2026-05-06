# frozen_string_literal: true

# Query object for Showtimes. Default to Showtime.today.
class ShowtimeQuery
  def initialize(params = {})
    @params = params
  end

  def call
    scope = Showtime.includes(:movie, :theater).joins(:movie).order("movies.title")
    scope = filter_by_date(scope)
    scope = filter_until_time(scope)
    scope = filter_from_time(scope)
  end

  private

  attr_reader :params

  def filter_by_date(scope)
    if params[:date].present?
      scope.merge(Showtime.by_date(Date.parse(params[:date])))
    else
      scope.merge(Showtime.today)
    end
  end

  def filter_until_time(scope)
    return scope unless params[:until_time].present?

    date = params[:date].presence || Date.current.to_s

    # Time.parse converts the user time into timezone time.
    # We don't want any conversion.
    time = Time.parse("#{date} #{params[:until_time]} UTC")

    scope.merge(Showtime.until_time(time))
  end

  def filter_from_time(scope)
    return scope unless params[:from_time].present?

    date = params[:date].presence || Date.current.to_s

    # Time.parse converts the user time into timezone time.
    # We don't want any conversion.
    time = Time.parse("#{date} #{params[:from_time]} UTC")

    scope.merge(Showtime.from_time(time))
  end
end

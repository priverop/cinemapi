# frozen_string_literal: true

# Query object for Movies. Default to Movie.today.
class MovieQuery
  def initialize(params = {})
    @params = params
  end

  def call
    scope = Movie.joins(:showtimes)
    scope = filter_by_date(scope)
  end

  private

  attr_reader :params

  def filter_by_date(scope)
    if params[:date].present?
      scope.merge(Movie.by_date(Date.parse(params[:date])))
    else
      scope.merge(Movie.today)
    end
  end
end

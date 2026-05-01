# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    if params[:date].present?
      @movies = Movie.joins(:showtimes).where(showtimes: { showtime: Date.parse(params[:date]).all_day })
    else
      @movies = Movie.today
    end
  end
end

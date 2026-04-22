# frozen_string_literal: true

class DashboardController < ApplicationController
  def home
    @theater_count = Theater.count
    @movie_count = Movie.count
    @recent_theaters = Theater.latest(5)
    @recent_movies = Movie.latest(5)
  end
end

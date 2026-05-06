# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @movies = MovieQuery.new(params).call
  end
end

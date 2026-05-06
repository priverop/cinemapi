# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @movies = ShowtimeQuery.new(params).call.group_by(&:movie)
  end
end

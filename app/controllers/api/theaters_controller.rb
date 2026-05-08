class Api::TheatersController < ApplicationController
  # GET /theaters
  def index
    @theaters = Theater.all

    render json: @theaters
  end

  # GET /theaters/1
  def show
      @theater = Theater.find(params.expect(:id))
    render json: @theater
  end
end

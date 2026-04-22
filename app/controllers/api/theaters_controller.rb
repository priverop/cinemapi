class Api::TheatersController < ApplicationController
  before_action :set_theater, only: %i[ show update destroy ]

  # GET /theaters
  def index
    @theaters = Theater.all

    render json: @theaters
  end

  # GET /theaters/1
  def show
    render json: @theater
  end

  # POST /theaters
  def create
    @theater = Theater.new(theater_params)

    if @theater.save
      render json: @theater, status: :created, location: api_theater_url(@theater)
    else
      render json: @theater.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT /theaters/1
  def update
    if @theater.update(theater_params)
      render json: @theater
    else
      render json: @theater.errors, status: :unprocessable_content
    end
  end

  # DELETE /theaters/1
  def destroy
    @theater.destroy!
  end

  private
    def set_theater
      @theater = Theater.find(params.expect(:id))
    end

    def theater_params
      params.expect(theater: [ :name, :location, :price, :discounted_price, discounted_days: [] ])
    end
end

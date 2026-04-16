# frozen_string_literal: true

class TheatersController < ApplicationController
  def index
    @theaters = Theater.all
  end

  def new
    @theater = Theater.new
  end

  def create
    @theater = Theater.new(theater_params)

    if @theater.save
      redirect_to @theater
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @theater = Theater.find(params[:id])
  end

  private

  def theater_params
    params.require(:theater).permit(:name, :location, :price, :discounted_price, :discounted_days)
  end
end

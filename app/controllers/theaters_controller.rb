# frozen_string_literal: true

class TheatersController < ApplicationController
  before_action :set_theater, only: %i[ show edit update destroy ]

  def index
    @theaters = Theater.all
  end

  def new
    @theater = Theater.new
  end

  def create
    @theater = Theater.new(theater_params)

    if @theater.save
      redirect_to @theater, notice: "Theater was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    if @theater.update(theater_params)
      redirect_to @theater, notice: "Theater was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @theater.destroy!

    redirect_to theaters_path, notice: "Theater was successfully removed.", status: :see_other
  end

  private

  def theater_params
    params.require(:theater).permit(:name, :location, :price, :discounted_price, :discounted_days)
  end

  def set_theater
    @theater = Theater.find(params[:id])
  end
end

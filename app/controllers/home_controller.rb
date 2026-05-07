# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @movies = ShowtimeQuery.new(params).call.group_by(&:movie)
  end

  def theater_search
    query = params[:query].to_s.strip
    @theaters = Theater.like_name(query).limit(5)

    render json: @theaters.map { |t| { id: t.id, name: t.name } }, status: :ok
  end
end

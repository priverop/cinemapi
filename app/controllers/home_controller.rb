# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @movies = ShowtimeQuery.new(params).call.group_by(&:movie)
  end

  def theater_search
    query = params[:query].to_s.strip
    @theaters = Theater.search_by_name(query)

    render json: @theaters.map { |t| { id: t.id, name: t.name } }, status: :ok
  end
end

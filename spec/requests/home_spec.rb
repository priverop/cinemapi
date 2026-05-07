# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Home", type: :request do
  let(:today) { Date.current }

  describe "GET /" do
    it "returns 200" do
      get root_path
      expect(response).to have_http_status(:ok)
    end

    it "shows only today's movies by default" do
      movie = create(:movie)
      create(:showtime, movie: movie, showtime: today.in_time_zone + 10.hours)
      create(:showtime, showtime: 2.days.from_now)

      get root_path

      expect(response.body).to include(movie.title)
    end

    it "filters by date" do
      movie    = create(:movie)
      tomorrow = today + 1.day
      create(:showtime, movie: movie, showtime: tomorrow.in_time_zone + 10.hours)

      get root_path, params: { date: tomorrow.to_s }

      expect(response.body).to include(movie.title)
    end

    it "filters by VOSE" do
      vose_movie   = create(:movie, title: "VOSE Movie")
      dubbed_movie = create(:movie, title: "Dubbed Movie")
      create(:showtime, :vose,   movie: vose_movie,   showtime: today.in_time_zone + 10.hours)
      create(:showtime, :dubbed, movie: dubbed_movie, showtime: today.in_time_zone + 10.hours)

      get root_path, params: { vose: "1" }

      expect(response.body).to include("VOSE Movie")
      expect(response.body).not_to include("Dubbed Movie")
    end

    it "filters by max duration" do
      short_movie = create(:movie, title: "Short Movie", duration: 90)
      long_movie  = create(:movie, title: "Epic Movie",  duration: 200)
      create(:showtime, movie: short_movie, showtime: today.in_time_zone + 10.hours)
      create(:showtime, movie: long_movie,  showtime: today.in_time_zone + 10.hours)

      get root_path, params: { date: today.to_s, duration: "120" }

      expect(response.body).to include("Short Movie")
      expect(response.body).not_to include("Epic Movie")
    end

    it "filters by max price" do
      cheap_theater  = create(:theater, name: "Budget Cinema", price: 5.0)
      pricey_theater = create(:theater, name: "Luxury Cinema", price: 20.0)
      cheap_movie    = create(:movie, title: "Budget Film")
      pricey_movie   = create(:movie, title: "Luxury Film")
      create(:showtime, theater: cheap_theater,  movie: cheap_movie,  showtime: today.in_time_zone + 10.hours)
      create(:showtime, theater: pricey_theater, movie: pricey_movie, showtime: today.in_time_zone + 10.hours)

      get root_path, params: { date: today.to_s, price: "8" }

      expect(response.body).to include("Budget Film")
      expect(response.body).not_to include("Luxury Film")
    end
  end

  describe "GET /theater_search" do
    it "returns matching theaters as JSON" do
      create(:theater, name: "Renoir Princesa")
      create(:theater, name: "Cinesa")

      get theater_search_path, params: { query: "renoir" }

      expect(response).to have_http_status(:ok)
      names = JSON.parse(response.body).map { |t| t["name"] }
      expect(names).to contain_exactly("Renoir Princesa")
    end

    it "returns empty array for no matches" do
      get theater_search_path, params: { query: "zzznomatch" }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to eq([])
    end

    it "limits results to 5" do
      6.times { |i| create(:theater, name: "Cine #{i}") }

      get theater_search_path, params: { query: "cine" }

      expect(JSON.parse(response.body).size).to eq(5)
    end

    it "handles empty query without error" do
      get theater_search_path, params: { query: "" }

      expect(response).to have_http_status(:ok)
    end

    it "returns id and name for each result" do
      theater = create(:theater, name: "Renoir")

      get theater_search_path, params: { query: "renoir" }

      result = JSON.parse(response.body).first
      expect(result.keys).to contain_exactly("id", "name")
      expect(result["id"]).to eq(theater.id)
      expect(result["name"]).to eq("Renoir")
    end
  end
end

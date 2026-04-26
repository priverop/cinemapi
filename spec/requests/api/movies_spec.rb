require "rails_helper"

RSpec.describe "Api::Movies", type: :request do
  let(:user) { create(:user) }
  let(:movie) { create(:movie) }

  before { sign_in_as(user) }

  describe "GET /api/movies" do
    it "returns success" do
      get api_movies_url, as: :json
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /api/movies" do
    it "creates a movie" do
      attrs = attributes_for(:movie)
      expect {
        post api_movies_url, params: { movie: attrs }, as: :json
      }.to change(Movie, :count).by(1)

      expect(response).to have_http_status(:created)
    end
  end

  describe "GET /api/movies/:id" do
    it "returns success" do
      get api_movie_url(movie), as: :json
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /api/movies/:id" do
    it "returns success" do
      patch api_movie_url(movie),
        params: { movie: { duration: movie.duration, genre: movie.genre, title: "Testing the movie" } },
        as: :json
      expect(response).to have_http_status(:success)
    end
  end

  describe "DELETE /api/movies/:id" do
    it "destroys the movie" do
      movie
      expect {
        delete api_movie_url(movie), as: :json
      }.to change(Movie, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end

require "rails_helper"

RSpec.describe "Movies", type: :request do
  let(:user) { create(:user) }
  let(:movie) { create(:movie) }

  before { sign_in_as(user) }

  describe "GET /movies" do
    it "returns success" do
      get movies_url
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /movies/new" do
    it "returns success" do
      get new_movie_url
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /movies" do
    it "creates a movie and redirects" do
      attrs = { name: movie.name, duration: movie.duration, genre: movie.genre }
      expect {
        post movies_url, params: { movie: attrs }
      }.to change(Movie, :count).by(1)

      expect(response).to redirect_to(movie_url(Movie.last))
    end
  end

  describe "GET /movies/:id" do
    it "returns success" do
      get movie_url(movie)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /movies/:id/edit" do
    it "returns success" do
      get edit_movie_url(movie)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /movies/:id" do
    it "updates and redirects" do
      patch movie_url(movie), params: { movie: {} }
      expect(response).to redirect_to(movie_url(movie))
    end
  end

  describe "DELETE /movies/:id" do
    it "destroys the movie and redirects" do
      movie
      expect {
        delete movie_url(movie)
      }.to change(Movie, :count).by(-1)

      expect(response).to redirect_to(movies_url)
    end
  end
end

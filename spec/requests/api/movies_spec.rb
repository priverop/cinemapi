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

  describe "GET /api/movies/:id" do
    it "returns success" do
      get api_movie_url(movie), as: :json
      expect(response).to have_http_status(:success)
    end
  end
end

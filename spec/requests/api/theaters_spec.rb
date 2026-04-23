require "rails_helper"

RSpec.describe "Api::Theaters", type: :request do
  let(:user) { create(:user) }
  let(:theater) { create(:theater) }

  before { sign_in_as(user) }

  describe "GET /api/theaters" do
    it "returns success" do
      get api_theaters_url, as: :json
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /api/theaters" do
    it "creates a theater" do
      attrs = { location: theater.location, name: theater.name, price: theater.price, discounted_price: theater.discounted_price, discounted_days: theater.discounted_days }
      expect {
        post api_theaters_url, params: { theater: attrs }, as: :json
      }.to change(Theater, :count).by(1)

      expect(response).to have_http_status(:created)
    end
  end

  describe "GET /api/theaters/:id" do
    it "returns success" do
      get api_theater_url(theater), as: :json
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /api/theaters/:id" do
    it "returns success" do
      patch api_theater_url(theater),
        params: { theater: { location: theater.location, name: theater.name, price: theater.price, discounted_price: theater.discounted_price, discounted_days: theater.discounted_days } },
        as: :json
      expect(response).to have_http_status(:success)
    end
  end

  describe "DELETE /api/theaters/:id" do
    it "destroys the theater" do
      theater
      expect {
        delete api_theater_url(theater), as: :json
      }.to change(Theater, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end

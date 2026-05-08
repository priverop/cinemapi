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

  describe "GET /api/theaters/:id" do
    it "returns success" do
      get api_theater_url(theater), as: :json
      expect(response).to have_http_status(:success)
    end
  end
end

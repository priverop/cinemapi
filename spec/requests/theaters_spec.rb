require "rails_helper"

RSpec.describe "Theaters", type: :request do
  let(:user) { create(:user) }
  let(:theater) { create(:theater) }

  before { sign_in_as(user) }

  describe "GET /theaters" do
    it "returns success" do
      get theaters_url
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /theaters/new" do
    it "returns success" do
      get new_theater_url
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /theaters" do
    it "creates a theater and redirects" do
      attrs = { name: "New Theater", location: "Madrid", price: 9.0, discounted_price: 4.5, discounted_days: [] }
      expect {
        post theaters_url, params: { theater: attrs }
      }.to change(Theater, :count).by(1)

      expect(response).to redirect_to(theater_url(Theater.last))
    end
  end

  describe "GET /theaters/:id" do
    it "returns success" do
      get theater_url(theater)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /theaters/:id/edit" do
    it "returns success" do
      get edit_theater_url(theater)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /theaters/:id" do
    it "updates and redirects" do
      patch theater_url(theater), params: { theater: { name: "Updated Name", discounted_days: [] } }
      expect(response).to redirect_to(theater_url(theater))
    end
  end

  describe "DELETE /theaters/:id" do
    it "destroys the theater and redirects" do
      theater
      expect {
        delete theater_url(theater)
      }.to change(Theater, :count).by(-1)

      expect(response).to redirect_to(theaters_url)
    end
  end
end

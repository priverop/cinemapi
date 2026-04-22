require "rails_helper"

RSpec.describe "Sessions", type: :request do
  let(:user) { create(:user) }

  describe "GET /session/new" do
    it "returns success" do
      get new_session_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /session" do
    context "with valid credentials" do
      it "redirects to root and sets session cookie" do
        post session_path, params: { email_address: user.email_address, password: "password" }
        expect(response).to redirect_to(root_path)
        expect(cookies[:session_id]).to be_present
      end
    end

    context "with invalid credentials" do
      it "redirects to new session and sets no cookie" do
        post session_path, params: { email_address: user.email_address, password: "wrong" }
        expect(response).to redirect_to(new_session_path)
        expect(cookies[:session_id]).to be_nil
      end
    end
  end

  describe "DELETE /session" do
    it "signs out and redirects to new session" do
      sign_in_as(user)
      delete session_path
      expect(response).to redirect_to(new_session_path)
      expect(cookies[:session_id]).to be_empty
    end
  end
end

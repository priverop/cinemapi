require "rails_helper"

RSpec.describe "Passwords", type: :request do
  let(:user) { create(:user) }

  describe "GET /password/new" do
    it "returns success" do
      get new_password_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /passwords" do
    it "enqueues reset email and redirects" do
      expect {
        post passwords_path, params: { email_address: user.email_address }
      }.to have_enqueued_mail(PasswordsMailer, :reset).with(user)

      expect(response).to redirect_to(new_session_path)
      follow_redirect!
      expect(response.body).to match(/reset instructions sent/i)
    end

    it "redirects but sends no email for unknown user" do
      expect {
        post passwords_path, params: { email_address: "missing@example.com" }
      }.not_to have_enqueued_mail

      expect(response).to redirect_to(new_session_path)
      follow_redirect!
      expect(response.body).to match(/reset instructions sent/i)
    end
  end

  describe "GET /password/:token/edit" do
    it "returns success with valid token" do
      get edit_password_path(user.password_reset_token)
      expect(response).to have_http_status(:success)
    end

    it "redirects with invalid token" do
      get edit_password_path("invalid token")
      expect(response).to redirect_to(new_password_path)
      follow_redirect!
      expect(response.body).to match(/reset link is invalid/i)
    end
  end

  describe "PUT /password/:token" do
    it "updates password and redirects" do
      expect {
        put password_path(user.password_reset_token), params: { password: "newpass", password_confirmation: "newpass" }
      }.to change { user.reload.password_digest }

      expect(response).to redirect_to(new_session_path)
      follow_redirect!
      expect(response.body).to match(/Password has been reset/i)
    end

    it "does not update password when confirmation does not match" do
      token = user.password_reset_token
      expect {
        put password_path(token), params: { password: "no", password_confirmation: "match" }
      }.not_to change { user.reload.password_digest }

      expect(response).to redirect_to(edit_password_path(token))
      follow_redirect!
      expect(response.body).to match(/Passwords did not match/i)
    end
  end
end

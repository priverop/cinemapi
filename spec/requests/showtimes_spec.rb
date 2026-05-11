require "rails_helper"

RSpec.describe "Showtimes", type: :request do
  let(:user) { create(:user) }
  let(:showtime) { create(:showtime) }

  before { sign_in_as(user) }

  describe "GET /showtimes/new" do
    it "returns success" do
      get new_showtime_url
      expect(response).to have_http_status(:success)
    end

    it "preselects movie and theater from params" do
      movie = create(:movie)
      theater = create(:theater)
      get new_showtime_url, params: { movie_id: movie.id, theater_id: theater.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /showtimes" do
    it "creates a showtime and redirects to the movie" do
      movie = create(:movie)
      theater = create(:theater)
      attrs = { movie_id: movie.id, theater_id: theater.id, showtime: 1.week.from_now, language: "vo" }
      expect {
        post showtimes_url, params: { showtime: attrs }
      }.to change(Showtime, :count).by(1)

      expect(response).to redirect_to(movie_url(movie))
    end

    it "re-renders new on invalid params" do
      post showtimes_url, params: { showtime: { movie_id: nil, theater_id: nil, showtime: nil } }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "GET /showtimes/:id/edit" do
    it "returns success" do
      get edit_showtime_url(showtime)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /showtimes/:id" do
    it "updates and redirects to the movie" do
      patch showtime_url(showtime), params: { showtime: { language: "vose" } }
      expect(response).to redirect_to(movie_url(showtime.movie))
      expect(showtime.reload.language).to eq("vose")
    end

    it "re-renders edit on invalid params" do
      patch showtime_url(showtime), params: { showtime: { showtime: "" } }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /showtimes/:id" do
    it "destroys the showtime and redirects to the movie" do
      movie = showtime.movie
      expect {
        delete showtime_url(showtime)
      }.to change(Showtime, :count).by(-1)

      expect(response).to redirect_to(movie_url(movie))
    end
  end
end

require "test_helper"

class Api::MoviesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @movie = movies(:one)
    @user = users(:one)
    sign_in_as(@user)
  end

  test "should get index" do
    get api_movies_url, as: :json
    assert_response :success
  end

  test "should create movie" do
    assert_difference("Movie.count") do
      post api_movies_url, params: { movie: { duration: @movie.duration, genre: @movie.genre, name: @movie.name } }, as: :json
    end

    assert_response :created
  end

  test "should show movie" do
    get api_movie_url(@movie), as: :json
    assert_response :success
  end

  test "should update movie" do
    patch api_movie_url(@movie), params: { movie: { duration: @movie.duration, genre: @movie.genre, name: @movie.name } }, as: :json
    assert_response :success
  end

  test "should destroy movie" do
    assert_difference("Movie.count", -1) do
      delete api_movie_url(@movie), as: :json
    end

    assert_response :no_content
  end
end

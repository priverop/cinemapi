require "test_helper"

class TheatersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @theater = theaters(:one)
  end

  test "should get index" do
    get theaters_url, as: :json
    assert_response :success
  end

  test "should create theater" do
    assert_difference("Theater.count") do
      post theaters_url, params: { theater: { location: @theater.location, name: @theater.name, price: @theater.price, discounted_price: @theater.discounted_price, discounted_days: @theater.discounted_days } }, as: :json
    end

    assert_response :created
  end

  test "should show theater" do
    get theater_url(@theater), as: :json
    assert_response :success
  end

  test "should update theater" do
    patch theater_url(@theater), params: { theater: { location: @theater.location, name: @theater.name, price: @theater.price, discounted_price: @theater.discounted_price, discounted_days: @theater.discounted_days } }, as: :json
    assert_response :success
  end

  test "should destroy theater" do
    assert_difference("Theater.count", -1) do
      delete theater_url(@theater), as: :json
    end

    assert_response :no_content
  end
end

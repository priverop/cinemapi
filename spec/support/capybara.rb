require "capybara/rails"
require "capybara/rspec"
require "selenium-webdriver"

if ENV["CAPYBARA_SERVER_PORT"]
  Capybara.server_host = "rails-app"
  Capybara.server_port = ENV["CAPYBARA_SERVER_PORT"]

  Capybara.register_driver :headless_chrome do |app|
    Capybara::Selenium::Driver.new(app,
      browser: :remote,
      url: "http://#{ENV["SELENIUM_HOST"]}:4444",
      options: Selenium::WebDriver::Chrome::Options.new.tap { |o| o.add_argument("--headless") })
  end
else
  Capybara.register_driver :headless_chrome do |app|
    Capybara::Selenium::Driver.new(app,
      browser: :chrome,
      options: Selenium::WebDriver::Chrome::Options.new.tap { |o| o.add_argument("--headless") })
  end
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :headless_chrome
    Capybara.current_window.resize_to(1400, 1400)
  end
end

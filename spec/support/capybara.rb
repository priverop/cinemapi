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
      options: Selenium::WebDriver::Chrome::Options.new.tap do |o|
        o.add_argument("--headless")
        o.add_argument("--no-sandbox")
        o.add_argument("--disable-dev-shm-usage")
      end)
  end
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :headless_chrome
    Capybara.current_window.resize_to(1400, 1400)
  end

  config.after(:each, type: :system) do |example|
    if example.exception
      screenshot_path = Rails.root.join("tmp/screenshots/#{example.full_description.gsub(/\s+/, '_')}.png")
      FileUtils.mkdir_p(screenshot_path.dirname)
      page.save_screenshot(screenshot_path.to_s)
    end
  end
end

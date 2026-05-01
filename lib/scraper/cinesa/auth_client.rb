# frozen_string_literal: true

require "ferrum"

module Scraper
  module Cinesa
    class AuthClient
      TIMEOUT = 30
      VISTA_HOST = "https://vwc.cinesa.es"
      HEADERS = {
        "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
      }

      class << self
        def fetch_headers(theater_url)
          Scraper.logger.info("Launching browser to capture JWT...")
          headers = with_browser { |page| capture_headers(page, theater_url) }
          raise Scraper::AuthRequiredError, "Could not capture JWT from #{theater_url} within #{TIMEOUT}s." unless headers

          Scraper.logger.info("JWT captured.")
          headers
        end

        private

        def with_browser
          browser = Ferrum::Browser.new(
            headless: "new",
            window_size: [ 1280, 800 ],
            browser_options: { "disable-blink-features" => "AutomationControlled" },
            timeout: TIMEOUT + 15
          )
          browser.headers.set(HEADERS)

          yield browser.page
        ensure
          browser&.quit
        end

        def capture_headers(page, theater_url)
          token = nil

          page.command("Network.enable")

          page.on("Network.requestWillBeSent") do |params|
            url = params.dig("request", "url").to_s
            next unless url.start_with?(VISTA_HOST)

            Scraper.logger.debug("[auth_client] vista request: #{url}")

            auth = find_auth_header(params.dig("request", "headers"))
            token ||= auth if auth&.start_with?("Bearer ")
          end

          begin
            page.go_to(theater_url)
          rescue Ferrum::TimeoutError => e
            Scraper.logger.warn("[auth_client] Navigation timed out: #{e.message}.")
          end

          Scraper.logger.debug("[auth_client] Navigation complete. URL: #{page.url}")

          deadline = Time.now + TIMEOUT
          sleep 0.2 until token || Time.now >= deadline

          token ? { "Authorization" => token } : nil
        end

        def find_auth_header(headers)
          return nil unless headers.is_a?(Hash)

          _, value = headers.find do |key, _value|
            key.to_s.casecmp("authorization").zero?
          end

          value
        end
      end
    end
  end
end

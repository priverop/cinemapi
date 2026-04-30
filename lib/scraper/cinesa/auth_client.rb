# frozen_string_literal: true

require "ferrum"

module Scraper
  module Cinesa
    class AuthClient
      TIMEOUT = 30
      VISTA_HOST = "https://vwc.cinesa.es"

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
            headless: false,
            window_size: [ 1280, 800 ],
            browser_options: { "disable-blink-features" => "AutomationControlled" },
            timeout: TIMEOUT + 15
          )

          yield browser.page
        ensure
          browser&.quit
        end

        def capture_headers(page, theater_url)
          token = nil
          request_urls = {}

          page.command("Network.enable")

          page.on("Network.requestWillBeSent") do |params|
            url = params.dig("request", "url").to_s
            request_urls[params["requestId"]] = url
            next unless url.start_with?(VISTA_HOST)

            debug "vista request: #{url}"

            auth = find_auth_header(params.dig("request", "headers"))
            token ||= auth if auth&.start_with?("Bearer ")
          end

          page.on("Network.requestWillBeSentExtraInfo") do |params|
            url = request_urls[params["requestId"]].to_s
            next unless url.start_with?(VISTA_HOST)

            auth = find_auth_header(params["headers"])
            token ||= auth if auth&.start_with?("Bearer ")
          end

          begin
            page.go_to(theater_url)
          rescue Ferrum::TimeoutError
            # Cloudflare challenge may still be resolving; continue polling
          end

          debug "Navigation complete. URL: #{page.url}"

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

        def debug(message)
          return unless ENV["AUTH_DEBUG"]

          $stdout.puts("[auth_client] #{message}")
          $stdout.flush
        end
      end
    end
  end
end

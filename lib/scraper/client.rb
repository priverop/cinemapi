# frozen_string_literal: true

require "net/http"
require "uri"

module Scraper
  # Open and read given website.
  class Client
    class << self
      def read(url)
        validate_url!(url)
        Scraper.logger.info("GET #{url}.")
        response = Net::HTTP.get_response(url)
        raise Scraper::HttpError, "HTTP #{response.code} fetching #{url}." unless response.is_a?(Net::HTTPSuccess)

        response.body
      end

      private

      def validate_url!(url)
        raise Scraper::InvalidUrlError, "Invalid URI '#{url}'." unless url.is_a?(URI) && Scraper.valid_http_url?(url)
      end
    end
  end
end

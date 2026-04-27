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
        Net::HTTP.get(url)
      end

      private

      def validate_url!(url)
        raise Scraper::InvalidUrlError, "Invalid URI '#{url}'." unless url.is_a?(URI::HTTP) && !url.host.to_s.empty?
      end
    end
  end
end

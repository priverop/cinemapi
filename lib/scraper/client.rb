# frozen_string_literal: true

require "net/http"
require "uri"

# TODO: Logger
module Scraper
  # Open and read given website.
  class Client
    class << self
      def read(url)
        validate_url!(url)

        uri = URI(url)
        Net::HTTP.get(uri)
      end

      private

      def validate_url!(url)
        raise Scraper::InvalidUrlError, "Invalid url '#{url}'." unless url.is_a?(String) && !url.nil? && !url.to_s.empty?
      end
    end
  end
end

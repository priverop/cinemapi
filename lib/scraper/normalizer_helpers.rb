# frozen_string_literal: true

require "uri"

module Scraper
  # Shared helpers for Normalizer classes.
  module NormalizerHelpers
    # Returns nil for blank input, the value when it is already an absolute URL,
    # or the value joined to base_url. With no base_url, relative values become nil.
    def normalize_poster_url(value, base_url: nil)
      return nil if value.nil? || value.strip.empty?
      return value if Scraper.valid_http_url?(value)
      return nil if base_url.nil?

      URI.join(base_url.to_s, value).to_s
    end

    # Returns the mapped symbol for the first matching key (regex match or string equal).
    # Raises Scraper::UnknownLanguageError for blank input or no match.
    def normalize_language_from_map(value, map)
      raise Scraper::UnknownLanguageError, "Unknown language #{value.inspect}." if value.nil? || value.to_s.strip.empty?

      input = value.to_s.strip
      _, symbol = map.find do |key, _|
        key.is_a?(Regexp) ? input.match?(key) : key.to_s.casecmp(input).zero?
      end

      raise Scraper::UnknownLanguageError, "Unknown language '#{value}'." if symbol.nil?

      symbol
    end
  end
end

# frozen_string_literal: true

require "uri"
require "active_support/core_ext/string/inflections"

module Scraper
  # Shared helpers for Normalizer classes.
  module NormalizerHelpers
    PARENTHETICAL_GROUPS = /\(.*?\)|\[.*?\]/
    TRAILING_LANG_TAG = /
      \s+(?:[-|:]\s+)?
      (?:
        V\.O\.S\.E\.?|V\.O\.S\.C\.?|V\.O\.S\.?|V\.O\.?|
        VOSE|VOSC|VOS|VO|VE|CAT|ESP|
        DOBLADA(?:\s+AL\s+ESPA[NÑ]OL)?
      )
      \s*\z
    /xi
    CLUB_SUFFIX = /\s*-\s*CLUB\s+ROSEBUD\s*\z/i
    ORDINAL_DOT = /(\d)\.(ª|º)/

    # Canonical title normalization shared by every scraper.
    # Strips parenthetical/bracket tags, trailing language markers, the
    # "- CLUB ROSEBUD" cycle suffix, and the ordinal dot in "3.ª"/"1.º".
    # Collapses whitespace and titleizes.
    def canonicalize_title(title)
      raise Scraper::InvalidMovieError, "Movie has an empty title." if title.nil? || title.strip.empty?

      title
        .gsub(PARENTHETICAL_GROUPS, " ")
        .sub(CLUB_SUFFIX, "")
        .sub(TRAILING_LANG_TAG, "")
        .gsub(ORDINAL_DOT, '\1\2')
        .strip
        .squeeze(" ")
        .titleize
    end

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

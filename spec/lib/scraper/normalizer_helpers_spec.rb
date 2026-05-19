# frozen_string_literal: true

require_relative '../../../lib/scraper'
require_relative '../../../lib/scraper/normalizer_helpers'

require 'spec_helper'

RSpec.describe Scraper::NormalizerHelpers do
  let(:host) { Class.new { include Scraper::NormalizerHelpers }.new }

  describe "#normalize_poster_url" do
    it "returns nil for blank input" do
      expect(host.normalize_poster_url(nil)).to be_nil
      expect(host.normalize_poster_url("")).to be_nil
      expect(host.normalize_poster_url("   ")).to be_nil
    end

    it "returns the value when already absolute" do
      expect(host.normalize_poster_url("https://x.example/img.jpg")).to eq("https://x.example/img.jpg")
    end

    it "returns nil when relative and no base_url" do
      expect(host.normalize_poster_url("/img.jpg")).to be_nil
    end

    it "joins relative paths to base_url" do
      expect(host.normalize_poster_url("/img.jpg", base_url: "https://x.example")).to eq("https://x.example/img.jpg")
    end
  end

  describe "#normalize_language_from_map" do
    let(:map) { { /subtitulada/ => :vose, "vo" => :vo } }

    it "matches regex keys" do
      expect(host.normalize_language_from_map("Versión Original subtitulada", map)).to eq(:vose)
    end

    it "matches string keys case-insensitively" do
      expect(host.normalize_language_from_map("VO", map)).to eq(:vo)
    end

    it "raises on blank input" do
      expect { host.normalize_language_from_map("", map) }.to raise_error(Scraper::UnknownLanguageError)
      expect { host.normalize_language_from_map(nil, map) }.to raise_error(Scraper::UnknownLanguageError)
    end

    it "raises on no match" do
      expect { host.normalize_language_from_map("klingon", map) }.to raise_error(Scraper::UnknownLanguageError)
    end
  end
end

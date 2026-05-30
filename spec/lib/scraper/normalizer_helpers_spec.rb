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

  describe "#canonicalize_title" do
    {
      "A LA CARA"                                  => "A La Cara",
      "A La Cara"                                  => "A La Cara",
      "A la cara"                                  => "A La Cara",
      "Asesinato En La 3.ª Planta"                 => "Asesinato En La 3ª Planta",
      "ASESINATO EN LA 3.ª PLANTA"                 => "Asesinato En La 3ª Planta",
      "Asesinato En La 3ª Planta"                  => "Asesinato En La 3ª Planta",
      "ASESINATO EN LA 3ª PLANTA"                  => "Asesinato En La 3ª Planta",
      "Asesinato en la 3ª planta"                  => "Asesinato En La 3ª Planta",
      "ASESINATO EN LA 3ª PLANTA - CLUB ROSEBUD"   => "Asesinato En La 3ª Planta",
      "Asesinato En La 3ª Planta Vose"             => "Asesinato En La 3ª Planta",
      "Asesinato En La 3ª Planta (VOSE)"           => "Asesinato En La 3ª Planta",
      "Asesinato En La 3ª Planta [VOSE]"           => "Asesinato En La 3ª Planta",
      "Asesinato En La 3ª Planta (V.O.S.E.)"       => "Asesinato En La 3ª Planta",
      "Asesinato En La 3ª Planta V.O.S.E."         => "Asesinato En La 3ª Planta",
      "Pelicula DOBLADA AL ESPAÑOL"                => "Pelicula",
      "Pelicula  con   espacios"                   => "Pelicula Con Espacios"
    }.each do |input, expected|
      it "normalizes #{input.inspect} to #{expected.inspect}" do
        expect(host.canonicalize_title(input)).to eq(expected)
      end
    end

    it "raises InvalidMovieError on blank input" do
      expect { host.canonicalize_title(nil) }.to raise_error(Scraper::InvalidMovieError)
      expect { host.canonicalize_title("") }.to raise_error(Scraper::InvalidMovieError)
      expect { host.canonicalize_title("   ") }.to raise_error(Scraper::InvalidMovieError)
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

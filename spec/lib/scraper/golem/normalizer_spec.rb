# frozen_string_literal: true

require_relative '../../../../lib/scraper/golem/normalizer'
require_relative '../../../../lib/scraper'

require 'spec_helper'

RSpec.describe Scraper::Golem::Normalizer do
  describe "#normalize" do
    let(:date) { "2026-05-20" }
    let(:base_url) { URI("https://www.golem.es") }
    let(:normalizer) { described_class.new(date: date, base_url: base_url) }

    context "valid input" do
      let(:input) do
        [
          {
            poster: "/golem/carteles/2026/April/1776857306.jpg",
            title: "El Amigo Inesperado (V.O.S.E.)",
            language: "vose",
            duration: "120 min.",
            showtimes: %w[16:00 20:20]
          },
          {
            poster: "/golem/carteles/2026/May/1777981733-13139.jpg",
            title: "Hangar Rojo",
            language: "vo",
            duration: nil,
            showtimes: %w[18:15 22:15]
          }
        ]
      end

      it "returns cleaned movies" do
        expect(normalizer.normalize(input)).to eq([
          {
            poster: "https://www.golem.es/golem/carteles/2026/April/1776857306.jpg",
            title: "El Amigo Inesperado",
            language: :vose,
            duration: 120,
            showtimes: [
              { date: Time.utc(2026, 5, 20, 16, 0) },
              { date: Time.utc(2026, 5, 20, 20, 20) }
            ]
          },
          {
            poster: "https://www.golem.es/golem/carteles/2026/May/1777981733-13139.jpg",
            title: "Hangar Rojo",
            language: :vo,
            duration: nil,
            showtimes: [
              { date: Time.utc(2026, 5, 20, 18, 15) },
              { date: Time.utc(2026, 5, 20, 22, 15) }
            ]
          }
        ])
      end
    end

    context "empty array" do
      it "raises ArgumentError" do
        expect { normalizer.normalize([]) }.to raise_error(ArgumentError, "Input array is empty.")
      end
    end

    context "non-array" do
      it "raises ArgumentError" do
        expect { normalizer.normalize("nope") }.to raise_error(ArgumentError, "Input should be an array.")
      end
    end

    context "unknown language" do
      it "raises UnknownLanguageError" do
        bad = [ { poster: nil, title: "X", language: "klingon", showtimes: %w[10:00] } ]
        expect { normalizer.normalize(bad) }.to raise_error(Scraper::UnknownLanguageError)
      end
    end

    context "blank language" do
      it "raises UnknownLanguageError" do
        bad = [ { poster: nil, title: "X", language: "", showtimes: %w[10:00] } ]
        expect { normalizer.normalize(bad) }.to raise_error(Scraper::UnknownLanguageError)
      end
    end
  end
end

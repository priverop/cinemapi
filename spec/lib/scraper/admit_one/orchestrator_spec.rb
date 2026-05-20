# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../lib/scraper'
require_relative '../../../../lib/scraper/client'
require_relative '../../../../lib/scraper/importer'
require_relative '../../../../lib/scraper/admit_one/movie_parser'
require_relative '../../../../lib/scraper/admit_one/normalizer'
require_relative '../../../../lib/scraper/base_orchestrator'
require_relative '../../../../lib/scraper/admit_one/orchestrator'

RSpec.describe Scraper::AdmitOne::Orchestrator do
  let(:theater)      { double("Theater", website: "https://madrid.cines-verdi.com/cartelera") }
  let(:movie_parser) { instance_double(Scraper::AdmitOne::MovieParser) }
  let(:normalizer)   { instance_double(Scraper::AdmitOne::Normalizer) }
  let(:importer)     { instance_double(Scraper::Importer, import: nil) }

  let(:parsed_movies) do
    [
      {
        title: "Movie A", directors: nil, duration: nil, genres: [], poster: nil, description: nil,
        showtimes: [
          { date: "20260520 20:00", language: "VOSE" },
          { date: "20260521 20:00", language: "VOSE" }
        ]
      },
      {
        title: "Movie B", directors: nil, duration: nil, genres: [], poster: nil, description: nil,
        showtimes: [ { date: "20260520 18:00", language: "CASTELLANO" } ]
      }
    ]
  end

  before do
    allow(Scraper::Client).to receive(:read).and_return("<html></html>")
    allow(Scraper::AdmitOne::MovieParser).to receive(:new).and_return(movie_parser)
    allow(movie_parser).to receive(:parse).and_return(parsed_movies)
    allow(Scraper::AdmitOne::Normalizer).to receive(:new).and_return(normalizer)
    allow(normalizer).to receive(:normalize).and_return([])
    allow(Scraper::Importer).to receive(:new).and_return(importer)
  end

  describe ".run" do
    it "fetches the cartelera HTML once" do
      described_class.run(theater)
      expect(Scraper::Client).to have_received(:read).exactly(1).times
    end

    it "imports one batch per distinct date" do
      described_class.run(theater)
      expect(importer).to have_received(:import).exactly(2).times
    end

    context "when one day fails" do
      before do
        calls = 0
        allow(Scraper::AdmitOne::Normalizer).to receive(:new) do
          calls += 1
          raise StandardError, "normalize error." if calls == 1

          normalizer
        end
      end

      it "continues with remaining days" do
        described_class.run(theater)
        expect(importer).to have_received(:import).exactly(1).times
      end
    end
  end
end

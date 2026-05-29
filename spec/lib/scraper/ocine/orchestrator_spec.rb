# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../lib/scraper'
require_relative '../../../../lib/scraper/client'
require_relative '../../../../lib/scraper/importer'
require_relative '../../../../lib/scraper/ocine/movie_parser'
require_relative '../../../../lib/scraper/ocine/normalizer'
require_relative '../../../../lib/scraper/ocine/orchestrator'

RSpec.describe Scraper::Ocine::Orchestrator do
  let(:theater)      { double("Theater", website: "https://ocineurbanxmadrid.es/") }
  let(:movie_parser) { instance_double(Scraper::Ocine::MovieParser) }
  let(:normalizer)   { instance_double(Scraper::Ocine::Normalizer) }
  let(:importer)     { instance_double(Scraper::Importer, import: nil) }
  let(:parsed)       { [ { title: "A" }, { title: "B" } ] }
  let(:normalized)   { [ { title: "A", showtimes: [] }, { title: "B", showtimes: [] } ] }

  before do
    allow(Scraper::Client).to receive(:read).and_return('{"data":[]}')
    allow(Scraper::Ocine::MovieParser).to receive(:new).and_return(movie_parser)
    allow(movie_parser).to receive(:parse).and_return(parsed)
    allow(Scraper::Ocine::Normalizer).to receive(:new).and_return(normalizer)
    allow(normalizer).to receive(:normalize).and_return(normalized)
    allow(Scraper::Importer).to receive(:new).and_return(importer)
  end

  describe ".run" do
    it "fetches the cartelera JSON exactly once" do
      described_class.run(theater)
      expect(Scraper::Client).to have_received(:read).once
    end

    it "passes parsed movies through the normalizer to the importer" do
      described_class.run(theater)
      expect(normalizer).to have_received(:normalize).with(parsed)
      expect(importer).to have_received(:import).with(normalized)
    end

    it "appends the cartelera JSON path to the theater website" do
      described_class.run(theater)
      expect(Scraper::Client).to have_received(:read) do |url|
        expect(url.to_s).to eq("https://ocineurbanxmadrid.es/components/com_cines/json/es_cartellera.json")
      end
    end

    context "when fetch fails" do
      before { allow(Scraper::Client).to receive(:read).and_raise(Scraper::HttpError, "boom.") }

      it "does not invoke the importer" do
        expect { described_class.run(theater) }.to raise_error(Scraper::HttpError)
        expect(importer).not_to have_received(:import)
      end
    end
  end
end

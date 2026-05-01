# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../lib/scraper'
require_relative '../../../../lib/scraper/client'
require_relative '../../../../lib/scraper/importer'
require_relative '../../../../lib/scraper/renoir/calendar_parser'
require_relative '../../../../lib/scraper/renoir/movie_parser'
require_relative '../../../../lib/scraper/renoir/normalizer'
require_relative '../../../../lib/scraper/renoir/orchestrator'

RSpec.describe Scraper::Renoir::Orchestrator do
  let(:theater)         { double("Theater", website: "https://cines.renoir.es/princesa/") }
  let(:calendar_parser) { instance_double(Scraper::Renoir::CalendarParser) }
  let(:movie_parser)    { instance_double(Scraper::Renoir::MovieParser) }
  let(:normalizer)      { instance_double(Scraper::Renoir::Normalizer) }
  let(:importer)        { instance_double(Scraper::Importer, import: nil) }

  let(:calendar_days) do
    [
      { url: "/cine/princesa/cartelera/?fecha=2026-04-23", date: "2026-04-23" },
      { url: "/cine/princesa/cartelera/?fecha=2026-04-24", date: "2026-04-24" }
    ]
  end

  before do
    allow(Scraper::Client).to receive(:read).and_return("<html></html>")
    allow(Scraper::Renoir::CalendarParser).to receive(:new).and_return(calendar_parser)
    allow(calendar_parser).to receive(:days).and_return(calendar_days)
    allow(Scraper::Renoir::MovieParser).to receive(:new).and_return(movie_parser)
    allow(movie_parser).to receive(:parse).and_return([])
    allow(Scraper::Renoir::Normalizer).to receive(:new).and_return(normalizer)
    allow(normalizer).to receive(:normalize).and_return([])
    allow(Scraper::Importer).to receive(:new).and_return(importer)
  end

  describe ".run" do
    context "when all days succeed" do
      it "imports data for each calendar day" do
        described_class.run(theater)
        expect(importer).to have_received(:import).exactly(2).times
      end

      it "fetches the main page and each day page" do
        described_class.run(theater)
        expect(Scraper::Client).to have_received(:read).exactly(3).times
      end
    end

    context "when one day fails" do
      before do
        calls = 0
        allow(Scraper::Renoir::MovieParser).to receive(:new) do
          calls += 1
          raise StandardError, "parse error." if calls == 1

          movie_parser
        end
      end

      it "continues and imports the remaining days" do
        described_class.run(theater)
        expect(importer).to have_received(:import).exactly(1).times
      end
    end
  end
end

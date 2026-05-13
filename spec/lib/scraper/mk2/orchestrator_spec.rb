# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../lib/scraper'
require_relative '../../../../lib/scraper/client'
require_relative '../../../../lib/scraper/importer'
require_relative '../../../../lib/scraper/mk2/calendar_parser'
require_relative '../../../../lib/scraper/mk2/movie_parser'
require_relative '../../../../lib/scraper/mk2/normalizer'
require_relative '../../../../lib/scraper/base_orchestrator'
require_relative '../../../../lib/scraper/mk2/orchestrator'

RSpec.describe Scraper::Mk2::Orchestrator do
  let(:theater)         { double("Theater", website: "https://www.cinepazmadrid.es/es/cartelera") }
  let(:calendar_parser) { instance_double(Scraper::Mk2::CalendarParser) }
  let(:movie_parser)    { instance_double(Scraper::Mk2::MovieParser) }
  let(:normalizer)      { instance_double(Scraper::Mk2::Normalizer) }
  let(:importer)        { instance_double(Scraper::Importer, import: nil) }

  let(:calendar_days) do
    [
      { num: 0, date: Date.new(2026, 5, 13) },
      { num: 1, date: Date.new(2026, 5, 14) }
    ]
  end

  before do
    allow(Scraper::Client).to receive(:read).and_return("<html></html>")
    allow(Scraper::Mk2::CalendarParser).to receive(:new).and_return(calendar_parser)
    allow(calendar_parser).to receive(:days).and_return(calendar_days)
    allow(Scraper::Mk2::MovieParser).to receive(:new).and_return(movie_parser)
    allow(movie_parser).to receive(:parse).and_return([])
    allow(Scraper::Mk2::Normalizer).to receive(:new).and_return(normalizer)
    allow(normalizer).to receive(:normalize).and_return([])
    allow(Scraper::Importer).to receive(:new).and_return(importer)
  end

  describe ".run" do
    context "when all days succeed" do
      it "fetches the page once" do
        described_class.run(theater)
        expect(Scraper::Client).to have_received(:read).exactly(1).times
      end

      it "imports data for each calendar day" do
        described_class.run(theater)
        expect(importer).to have_received(:import).exactly(2).times
      end
    end

    context "when one day fails" do
      before do
        calls = 0
        allow(Scraper::Mk2::MovieParser).to receive(:new) do
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

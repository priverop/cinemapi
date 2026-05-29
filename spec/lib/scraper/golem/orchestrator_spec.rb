# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../lib/scraper'
require_relative '../../../../lib/scraper/client'
require_relative '../../../../lib/scraper/importer'
require_relative '../../../../lib/scraper/golem/calendar_parser'
require_relative '../../../../lib/scraper/golem/movie_parser'
require_relative '../../../../lib/scraper/golem/detail_parser'
require_relative '../../../../lib/scraper/golem/normalizer'
require_relative '../../../../lib/scraper/base_orchestrator'
require_relative '../../../../lib/scraper/golem/orchestrator'

RSpec.describe Scraper::Golem::Orchestrator do
  let(:theater)         { double("Theater", website: "https://www.golem.es/golem/golem-madrid") }
  let(:calendar_parser) { instance_double(Scraper::Golem::CalendarParser) }
  let(:movie_parser)    { instance_double(Scraper::Golem::MovieParser) }
  let(:detail_parser)   { instance_double(Scraper::Golem::DetailParser, parse: { duration: "159 min." }) }
  let(:normalizer)      { instance_double(Scraper::Golem::Normalizer) }
  let(:importer)        { instance_double(Scraper::Importer, import: nil) }

  let(:calendar_days) do
    [
      { url: "/golem/golem-madrid/20260520", date: "2026-05-20" },
      { url: "/golem/golem-madrid/20260521", date: "2026-05-21" }
    ]
  end

  before do
    allow(Scraper::Client).to receive(:read).and_return("<html></html>")
    allow(Scraper::Golem::CalendarParser).to receive(:new).and_return(calendar_parser)
    allow(calendar_parser).to receive(:days).and_return(calendar_days)
    allow(Scraper::Golem::MovieParser).to receive(:new).and_return(movie_parser)
    allow(movie_parser).to receive(:parse).and_return([])
    allow(Scraper::Golem::DetailParser).to receive(:new).and_return(detail_parser)
    allow(Scraper::Golem::Normalizer).to receive(:new).and_return(normalizer)
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

    context "when movies have detail URLs" do
      let(:movies_day1) do
        [
          { title: "A", detail_url: "/golem/pelicula/A", showtimes: %w[16:00] },
          { title: "B", detail_url: "/golem/pelicula/B", showtimes: %w[18:00] },
          { title: "A again", detail_url: "/golem/pelicula/A", showtimes: %w[20:00] }
        ]
      end

      let(:captured) { [] }

      before do
        allow(movie_parser).to receive(:parse).and_return(movies_day1, [])
        allow(normalizer).to receive(:normalize) { |movies| captured << movies; [] }
      end

      it "fetches each unique detail page once per day and merges duration" do
        described_class.run(theater)
        expect(Scraper::Golem::DetailParser).to have_received(:new).exactly(2).times
        day1 = captured.first
        expect(day1).to all(include(duration: "159 min."))
        expect(day1).to all(satisfy { |m| !m.key?(:detail_url) })
      end
    end

    context "when one day fails" do
      before do
        calls = 0
        allow(Scraper::Golem::MovieParser).to receive(:new) do
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

# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../lib/scraper'
require_relative '../../../../lib/scraper/client'
require_relative '../../../../lib/scraper/importer'
require_relative '../../../../lib/scraper/embajadores/calendar_parser'
require_relative '../../../../lib/scraper/embajadores/movie_parser'
require_relative '../../../../lib/scraper/embajadores/normalizer'
require_relative '../../../../lib/scraper/base_orchestrator'
require_relative '../../../../lib/scraper/embajadores/base_embajadores_orchestrator'
require_relative '../../../../lib/scraper/embajadores/cabeza_orchestrator'
require_relative '../../../../lib/scraper/embajadores/rio_orchestrator'

RSpec.describe Scraper::Embajadores::CabezaOrchestrator do
  let(:theater)         { double("Theater", website: "https://cinesembajadores.es/madrid/cartelera-del-dia/?ciudad=madrid") }
  let(:calendar_parser) { instance_double(Scraper::Embajadores::CalendarParser) }
  let(:movie_parser)    { instance_double(Scraper::Embajadores::MovieParser) }
  let(:normalizer)      { instance_double(Scraper::Embajadores::Normalizer) }
  let(:importer)        { instance_double(Scraper::Importer, import: nil) }

  let(:calendar_days) do
    [
      { url: "https://cinesembajadores.es/madrid/cartelera-del-dia/?ciudad=madrid",        date: Date.new(2026, 5, 13) },
      { url: "https://cinesembajadores.es/madrid/cartelera-del-dia/?dia=1&ciudad=madrid",  date: Date.new(2026, 5, 14) }
    ]
  end

  before do
    allow(Scraper::Client).to receive(:read).and_return("<html></html>")
    allow(Scraper::Embajadores::CalendarParser).to receive(:new).and_return(calendar_parser)
    allow(calendar_parser).to receive(:days).and_return(calendar_days)
    allow(Scraper::Embajadores::MovieParser).to receive(:new).and_return(movie_parser)
    allow(movie_parser).to receive(:parse).and_return([])
    allow(Scraper::Embajadores::Normalizer).to receive(:new).and_return(normalizer)
    allow(normalizer).to receive(:normalize).and_return([])
    allow(Scraper::Importer).to receive(:new).and_return(importer)
  end

  describe ".run" do
    context "when all days succeed" do
      it "fetches once for calendar and once per day" do
        described_class.run(theater)
        expect(Scraper::Client).to have_received(:read).exactly(3).times
      end

      it "initializes normalizer with cabeza venue slug" do
        described_class.run(theater)
        expect(Scraper::Embajadores::Normalizer).to have_received(:new).with(anything, "cineembajadores").at_least(:once)
      end

      it "imports data for each calendar day" do
        described_class.run(theater)
        expect(importer).to have_received(:import).exactly(2).times
      end
    end

    context "when one day fails" do
      before do
        calls = 0
        allow(Scraper::Embajadores::MovieParser).to receive(:new) do
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

RSpec.describe Scraper::Embajadores::RioOrchestrator do
  let(:theater) { double("Theater", website: "https://cinesembajadores.es/madrid/cartelera-del-dia/?ciudad=madrid") }
  let(:normalizer) { instance_double(Scraper::Embajadores::Normalizer) }

  let(:calendar_day) { { url: "https://cinesembajadores.es/madrid/cartelera-del-dia/?ciudad=madrid", date: Date.new(2026, 5, 13) } }
  let(:movie_parser) { instance_double(Scraper::Embajadores::MovieParser) }
  let(:importer)     { instance_double(Scraper::Importer, import: nil) }

  before do
    allow(Scraper::Client).to receive(:read).and_return("<html></html>")
    allow(Scraper::Embajadores::CalendarParser).to receive(:new).and_return(
      instance_double(Scraper::Embajadores::CalendarParser, days: [ calendar_day ])
    )
    allow(Scraper::Embajadores::MovieParser).to receive(:new).and_return(movie_parser)
    allow(movie_parser).to receive(:parse).and_return([])
    allow(Scraper::Embajadores::Normalizer).to receive(:new).and_return(normalizer)
    allow(normalizer).to receive(:normalize).and_return([])
    allow(Scraper::Importer).to receive(:new).and_return(importer)
  end

  it "initializes normalizer with rio venue slug" do
    described_class.run(theater)
    expect(Scraper::Embajadores::Normalizer).to have_received(:new).with(anything, "cineembajadoresrio").at_least(:once)
  end
end

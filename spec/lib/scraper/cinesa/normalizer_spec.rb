# frozen_string_literal: true

require_relative '../../../../lib/scraper/cinesa/normalizer'
require_relative '../../../../lib/scraper'

require 'spec_helper'

RSpec.describe Scraper::Cinesa::Normalizer do
  describe ".normalize" do
    context "when passing an array of non clean movies" do
      let(:input) do
        [ {
          description: "El profesor de ciencias Ryland Grace (Ryan Gosling) se despierta en una nave espacial a años luz de casa sin recordar quién es ni cómo ha llegado hasta allí. A medida que recupera la memoria, empieza a descubrir su misión: resolver el enigma de la misteriosa sustancia que provoca la extinción del sol. Deberá recurrir a sus conocimientos científicos y a sus ideas poco ortodoxas para salvar todo lo que hay en la Tierra de la extinción... pero una amistad inesperada significa que quizá no tenga que hacerlo solo.",
          directors: [ { "givenName" => "Phil", "familyName" => "Lord", "middleName" => nil }, { "givenName" => "Christopher", "familyName" => "Miller", "middleName" => nil } ],
          duration: 156,
          genres: [ "Acción", "Aventura", "Ciencia ficción" ],
          poster_id: "f741e25d-2e02-44e5-bc0f-5460117e540a",
          showtimes: [ { date: "2026-04-27T17:45:00+02:00", language: [ "Vose" ] }, { date: "2026-04-27T21:20:00+02:00", language: [] } ],
          title: "Proyecto Salvación",
          trailer: "https://www.youtube.com/watch?v=in-lUuKi0eE"
        },
        {
          description: "Una cantautora se suicida en el jardín de su amante después de ser abandonada por éste. Pero su fantasma se queda en la mansión. Sus ansias de venganza desencadenarán una espiral de locura, horror y muerte que convertirá la vida de la familia en un infierno. Sólo la pequeña Patti, médium espiritista, entenderá la naturaleza del Mal al que se enfrentan...",
          directors: [ { "givenName" => "Miguel Ángel", "familyName" => "Lamata", "middleName" => nil } ],
          duration: 91,
          genres: [ "Terror" ],
          poster_id: "ead7d23f-c8bc-4370-a332-fcf625acc05b",
          showtimes: [ { date: "2026-04-27T19:10:00+02:00", language: [ "Es Nuestro Cine", "Terror y Suspense" ] }, { date: "2026-04-27T21:30:00+02:00", language: [ "Es Nuestro Cine", "Terror y Suspense" ] } ],
          title: "La ahorcada",
          trailer: "https://www.youtube.com/watch?v=bQOcBnTGpuk"
        }
        ]
      end

      it "returns the clean movies" do
        expect(described_class.normalize(input)).to match([
        {
          description: "El profesor de ciencias Ryland Grace (Ryan Gosling) se despierta en una nave espacial a años luz de casa sin recordar quién es ni cómo ha llegado hasta allí. A medida que recupera la memoria, empieza a descubrir su misión: resolver el enigma de la misteriosa sustancia que provoca la extinción del sol. Deberá recurrir a sus conocimientos científicos y a sus ideas poco ortodoxas para salvar todo lo que hay en la Tierra de la extinción... pero una amistad inesperada significa que quizá no tenga que hacerlo solo.",
          directors: [ "Phil Lord", "Christopher Miller" ],
          duration: 156,
          genres: [ "Acción", "Aventura", "Ciencia ficción" ],
          poster: "https://film-cdn.moviexchange.com/api/cdn/release/f741e25d-2e02-44e5-bc0f-5460117e540a/media/Poster",
          showtimes: [ { date: DateTime.parse("2026-04-27T17:45:00+02:00"), language: :vose }, { date: DateTime.parse("2026-04-27T21:20:00+02:00"), language: :dubbed } ],
          title: "Proyecto Salvación",
          trailer: "https://www.youtube.com/watch?v=in-lUuKi0eE"
        },
        {
          description: "Una cantautora se suicida en el jardín de su amante después de ser abandonada por éste. Pero su fantasma se queda en la mansión. Sus ansias de venganza desencadenarán una espiral de locura, horror y muerte que convertirá la vida de la familia en un infierno. Sólo la pequeña Patti, médium espiritista, entenderá la naturaleza del Mal al que se enfrentan...",
          directors: [ "Miguel Ángel Lamata" ],
          duration: 91,
          genres: [ "Terror" ],
          poster: "https://film-cdn.moviexchange.com/api/cdn/release/ead7d23f-c8bc-4370-a332-fcf625acc05b/media/Poster",
          showtimes: [ { date: DateTime.parse("2026-04-27T19:10:00+02:00"), language: :vo }, { date: DateTime.parse("2026-04-27T21:30:00+02:00"), language: :vo } ],
          title: "La ahorcada",
          trailer: "https://www.youtube.com/watch?v=bQOcBnTGpuk"
        }
        ])
      end
    end

    context "when mapping showtime language attributes" do
      let(:movie) do
        {
          description: "desc",
          directors: [],
          duration: 100,
          genres: [],
          poster_id: "p",
          title: "Test",
          trailer: nil,
          showtimes: showtimes
        }
      end

      subject(:languages) { described_class.normalize([ movie ]).first[:showtimes].map { |s| s[:language] } }

      context "with Vose attribute" do
        let(:showtimes) { [ { date: "2026-04-27T17:45:00+02:00", language: [ "Vose" ] } ] }
        it { expect(languages).to eq([ :vose ]) }
      end

      context "with Es Nuestro Cine attribute" do
        let(:showtimes) { [ { date: "2026-04-27T17:45:00+02:00", language: [ "Es Nuestro Cine" ] } ] }
        it { expect(languages).to eq([ :vo ]) }
      end

      context "with both Vose and Es Nuestro Cine" do
        let(:showtimes) { [ { date: "2026-04-27T17:45:00+02:00", language: [ "Es Nuestro Cine", "Vose" ] } ] }
        it { expect(languages).to eq([ :vose ]) }
      end

      context "with Es Nuestro Cine plus a genre tag" do
        let(:showtimes) { [ { date: "2026-04-27T17:45:00+02:00", language: [ "Es Nuestro Cine", "Terror y Suspense" ] } ] }
        it { expect(languages).to eq([ :vo ]) }
      end

      context "with no language-relevant attributes" do
        let(:showtimes) { [ { date: "2026-04-27T17:45:00+02:00", language: [] } ] }
        it { expect(languages).to eq([ :dubbed ]) }
      end
    end

    context "when passing an empty array" do
      it 'raises ArgumentError' do
        expect do
          described_class.normalize([])
        end.to raise_error ArgumentError, "Input array is empty."
      end
    end

    context "when not passing an array" do
      it 'raises ArgumentError' do
        expect do
          described_class.normalize("hello")
        end.to raise_error ArgumentError, "Input should be an array."
      end
    end
  end
end

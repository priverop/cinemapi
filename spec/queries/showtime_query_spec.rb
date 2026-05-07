# frozen_string_literal: true

require "rails_helper"

RSpec.describe ShowtimeQuery do
  let(:today) { Date.current }
  let(:tomorrow) { Date.current + 1.day }

  def at(date, hour)
    Time.utc(date.year, date.month, date.day, hour, 0, 0)
  end

  describe "default — no params" do
    it "returns only today's showtimes" do
      shown  = create(:showtime, showtime: at(today, 14))
      hidden = create(:showtime, showtime: at(tomorrow, 14))

      result = described_class.new({}).call

      expect(result).to include(shown)
      expect(result).not_to include(hidden)
    end
  end

  describe ":date" do
    it "filters to the given date" do
      shown  = create(:showtime, showtime: at(tomorrow, 14))
      hidden = create(:showtime, showtime: at(today, 14))

      result = described_class.new(date: tomorrow.to_s).call

      expect(result).to include(shown)
      expect(result).not_to include(hidden)
    end
  end

  describe ":from_time" do
    it "excludes showtimes before the given time" do
      early = create(:showtime, showtime: at(today, 10))
      late  = create(:showtime, showtime: at(today, 16))

      result = described_class.new(date: today.to_s, from_time: "12:00").call

      expect(result).not_to include(early)
      expect(result).to include(late)
    end
  end

  describe ":until_time" do
    it "excludes showtimes after the given time" do
      early = create(:showtime, showtime: at(today, 10))
      late  = create(:showtime, showtime: at(today, 20))

      result = described_class.new(date: today.to_s, until_time: "15:00").call

      expect(result).to include(early)
      expect(result).not_to include(late)
    end
  end

  describe ":duration" do
    it "excludes movies longer than the max" do
      short_movie = create(:movie, duration: 90)
      long_movie  = create(:movie, duration: 180)
      shown  = create(:showtime, movie: short_movie, showtime: at(today, 14))
      hidden = create(:showtime, movie: long_movie,  showtime: at(today, 14))

      result = described_class.new(date: today.to_s, duration: "120").call

      expect(result).to include(shown)
      expect(result).not_to include(hidden)
    end
  end

  describe ":price" do
    it "excludes theaters above the max price" do
      cheap  = create(:theater, price: 6.0)
      pricey = create(:theater, price: 15.0)
      shown  = create(:showtime, theater: cheap,  showtime: at(today, 14))
      hidden = create(:showtime, theater: pricey, showtime: at(today, 14))

      result = described_class.new(date: today.to_s, price: "10").call

      expect(result).to include(shown)
      expect(result).not_to include(hidden)
    end
  end

  describe ":vose" do
    it "filters to VOSE only when '1'" do
      vose_show   = create(:showtime, :vose,   showtime: at(today, 14))
      dubbed_show = create(:showtime, :dubbed, showtime: at(today, 14))

      result = described_class.new(date: today.to_s, vose: "1").call

      expect(result).to include(vose_show)
      expect(result).not_to include(dubbed_show)
    end

    it "ignores the vose filter when not '1'" do
      dubbed_show = create(:showtime, :dubbed, showtime: at(today, 14))

      result = described_class.new(date: today.to_s, vose: "0").call

      expect(result).to include(dubbed_show)
    end
  end

  describe ":theaters" do
    it "filters by theater name" do
      renoir = create(:theater, name: "Renoir")
      cinesa = create(:theater, name: "Cinesa")
      shown  = create(:showtime, theater: renoir, showtime: at(today, 14))
      hidden = create(:showtime, theater: cinesa, showtime: at(today, 14))

      result = described_class.new(date: today.to_s, theaters: [ "Renoir" ]).call

      expect(result).to include(shown)
      expect(result).not_to include(hidden)
    end
  end

  describe "combined filters" do
    it "composes multiple filters" do
      theater = create(:theater, name: "Renoir", price: 6.0)
      short   = create(:movie, duration: 90)
      long    = create(:movie, duration: 200)
      shown  = create(:showtime, theater: theater, movie: short, showtime: at(today, 14), language: :vose)
      hidden = create(:showtime, theater: theater, movie: long,  showtime: at(today, 14), language: :vose)

      result = described_class.new(
        date: today.to_s, vose: "1", duration: "120", theaters: [ "Renoir" ]
      ).call

      expect(result).to include(shown)
      expect(result).not_to include(hidden)
    end
  end
end

# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Home filters", type: :system do
  let(:today) { Date.current }
  let(:theater) { create(:theater, name: "Renoir Princesa", price: 8.0) }
  let(:other_theater) { create(:theater, name: "Cinesa Callao", price: 8.0) }

  describe "date and time range filters" do
    let(:morning_movie) { create(:movie, title: "Morning Show") }
    let(:evening_movie) { create(:movie, title: "Evening Show") }

    before do
      create(:showtime, theater: theater, movie: morning_movie,
             showtime: Time.utc(today.year, today.month, today.day, 10, 0, 0))
      create(:showtime, theater: theater, movie: evening_movie,
             showtime: Time.utc(today.year, today.month, today.day, 20, 0, 0))
      visit root_path
    end

    it "filters by from_time" do
      page.execute_script(<<~JS)
        const date = document.querySelector('input[name="date"]');
        date.value = '#{today}';
        date.dispatchEvent(new Event('change', { bubbles: true }));
      JS
      page.execute_script(<<~JS)
        const ft = document.querySelector('input[name="from_time"]');
        ft.value = '14:00';
        ft.dispatchEvent(new Event('change', { bubbles: true }));
      JS

      expect(page).to have_content("Evening Show")
      expect(page).not_to have_content("Morning Show")
    end

    it "filters by until_time" do
      page.execute_script(<<~JS)
        const date = document.querySelector('input[name="date"]');
        date.value = '#{today}';
        date.dispatchEvent(new Event('change', { bubbles: true }));
      JS
      page.execute_script(<<~JS)
        const ut = document.querySelector('input[name="until_time"]');
        ut.value = '15:00';
        ut.dispatchEvent(new Event('change', { bubbles: true }));
      JS

      expect(page).to have_content("Morning Show")
      expect(page).not_to have_content("Evening Show")
    end
  end

  describe "theater pill filter" do
    let(:renoir_movie) { create(:movie, title: "Renoir Exclusive") }
    let(:cinesa_movie) { create(:movie, title: "Cinesa Exclusive") }

    before do
      create(:showtime, theater: theater,       movie: renoir_movie, showtime: today.in_time_zone + 14.hours)
      create(:showtime, theater: other_theater, movie: cinesa_movie, showtime: today.in_time_zone + 14.hours)
      visit root_path
    end

    it "filters movies to the selected theater" do
      find("input[placeholder='Search theater...']").set("Ren")

      expect(page).to have_css("[data-theaters-autocomplete-target='results'] li", text: "Renoir Princesa")
      find("[data-theaters-autocomplete-target='results'] li", text: "Renoir Princesa").click

      expect(page).to have_css("[data-pill-name]", text: "Renoir Princesa")
      expect(page).to have_content("Renoir Exclusive")
      expect(page).not_to have_content("Cinesa Exclusive")
    end
  end

  describe "VOSE filter" do
    let(:vose_movie)   { create(:movie, title: "Original Version") }
    let(:dubbed_movie) { create(:movie, title: "Dubbed Version") }

    before do
      create(:showtime, :vose,   theater: theater, movie: vose_movie,   showtime: today.in_time_zone + 14.hours)
      create(:showtime, :dubbed, theater: theater, movie: dubbed_movie, showtime: today.in_time_zone + 14.hours)
      visit root_path
    end

    it "shows only VOSE movies when checked" do
      check "vose"

      expect(page).to have_content("Original Version")
      expect(page).not_to have_content("Dubbed Version")
    end
  end

  describe "duration and price sliders" do
    let(:short_movie) { create(:movie, title: "Short Film",  duration: 90) }
    let(:long_movie)  { create(:movie, title: "Epic Saga",   duration: 270) }
    let(:cheap)       { create(:theater, name: "Budget Cine", price: 5.0) }
    let(:pricey)      { create(:theater, name: "Luxury Cine", price: 18.0) }

    before do
      create(:showtime, theater: theater, movie: short_movie, showtime: today.in_time_zone + 14.hours)
      create(:showtime, theater: theater, movie: long_movie,  showtime: today.in_time_zone + 14.hours)
      create(:showtime, theater: cheap,  movie: short_movie, showtime: today.in_time_zone + 14.hours)
      create(:showtime, theater: pricey, movie: short_movie, showtime: today.in_time_zone + 14.hours)
      visit root_path
    end

    it "filters out movies over the duration max" do
      page.execute_script(<<~JS)
        const input = document.querySelector('input[name="duration"]');
        input.value = '120';
        input.dispatchEvent(new Event('input', { bubbles: true }));
        input.dispatchEvent(new Event('change', { bubbles: true }));
      JS

      expect(page).to have_content("Short Film")
      expect(page).not_to have_content("Epic Saga")
    end

    it "filters out theaters over the price max" do
      page.execute_script(<<~JS)
        const input = document.querySelector('input[name="price"]');
        input.value = '8';
        input.dispatchEvent(new Event('input', { bubbles: true }));
        input.dispatchEvent(new Event('change', { bubbles: true }));
      JS

      within("turbo-frame#movies") do
        expect(page).to have_content("Short Film")
      end

      expect(page).not_to have_css("turbo-frame#movies", text: "Luxury Cine")
    end
  end
end

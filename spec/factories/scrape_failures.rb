FactoryBot.define do
  factory :scrape_failure do
    scrape_run
    context { "2026-05-28" }
    error_message { "Something failed." }
  end
end

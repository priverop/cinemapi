FactoryBot.define do
  factory :scrape_run do
    theater
    status { :running }
    items_ok { 0 }
    items_failed { 0 }
  end
end

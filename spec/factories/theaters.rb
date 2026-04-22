FactoryBot.define do
  factory :theater do
    sequence(:name) { |n| "Theater #{n}" }
    sequence(:location) { |n| "Location #{n}" }
    price { 8.90 }
    discounted_price { 4.50 }
    discounted_days { [ "monday", "wednesday" ] }
  end
end

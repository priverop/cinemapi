FactoryBot.define do
  factory :movie do
    sequence(:name) { |n| "Movie #{n}" }
    duration { 120 }
    genre { "Drama" }
  end
end

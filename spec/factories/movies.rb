FactoryBot.define do
  factory :movie do
    sequence(:title) { |n| "Movie #{n}" }
    duration { 120 }
    genre { "Drama" }
  end
end

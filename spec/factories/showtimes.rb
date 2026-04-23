FactoryBot.define do
  factory :showtime do
    association :movie
    association :theater
    showtime { 1.week.from_now }
  end
end

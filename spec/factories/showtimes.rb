FactoryBot.define do
  factory :showtime do
    association :movie
    association :theater
    showtime { 1.week.from_now }
    language { :dubbed }

    trait :vose   do language { :vose }   end
    trait :dubbed do language { :dubbed } end
    trait :vo     do language { :vo }     end
  end
end

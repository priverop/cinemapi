class Theater < ApplicationRecord
  has_many :showtimes

  has_many :movies, through: :showtimes

  serialize :discounted_days, coder: JSON

  validates :name, :location, :price, :discounted_price, presence: true
end

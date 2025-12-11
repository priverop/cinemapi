class Theater < ApplicationRecord
  has_many :showtimes, dependent: :destroy

  has_many :movies, through: :showtimes

  serialize :discounted_days, coder: JSON

  validates :name, :location, :price, :discounted_price, :discounted_days, presence: true

  ## Return regular price or discounted price, depending on the date
  def price_for_day(date)
    date.strftime("%A").downcase.in?(discounted_days) ? discounted_price : price
  end
end

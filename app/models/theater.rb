class Theater < ApplicationRecord
  before_create :store_discounted_days

  has_many :showtimes, dependent: :destroy
  has_many :movies, through: :showtimes

  serialize :discounted_days, coder: JSON

  validates :name, :location, :price, presence: true

  ## Return regular price or discounted price, depending on the date
  def price_for_day(date)
    date.strftime("%A").downcase.in?(discounted_days) ? discounted_price : price
  end

  def discounted_days_string
    discounted_days.filter_map(&:capitalize).join(", ")
  end

  # Get the latests n theaters
  def self.latest(n)
    order(created_at: :desc).limit(n)
  end

  private

  # TODO: change this for a checkbox and proper design
  def store_discounted_days
    self.discounted_days = discounted_days.split(", ") if self.discounted_days.nil?
  end
end

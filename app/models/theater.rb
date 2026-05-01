class Theater < ApplicationRecord
  enum :scraper_key, manual: 0, renoir: 1, cinesa: 2
  scope :enabled, -> { where(is_enabled: true) }

  has_many :showtimes, dependent: :destroy
  has_many :movies, through: :showtimes

  serialize :discounted_days, coder: JSON

  validates :name, :location, :price, presence: true
  validates :website, url: { allow_blank: true }

  ## Return regular price or discounted price, depending on the date
  def price_for_day(date)
    date.strftime("%A").downcase.in?(discounted_days) ? discounted_price : price
  end

  def discounted_days_string
    discounted_days.to_a.map(&:capitalize).join(", ")
  end

  # Get the latests n theaters
  def self.latest(n)
    order(created_at: :desc).limit(n)
  end

  def display_name
    name
  end
end

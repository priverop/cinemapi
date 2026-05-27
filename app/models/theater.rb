class Theater < ApplicationRecord
  enum :scraper_key, manual: 0, renoir: 1, cinesa: 2, mk2: 3, embajadores_cabeza: 4, embajadores_rio: 5, golem: 6, admit_one: 7, zumzeig: 8, zoco: 9, cines_abc: 10, ocine: 11, verdi_barcelona: 12, malda: 13
  scope :enabled, -> { where(is_enabled: true) }
  scope :by_price, ->(price) { where("price <= ?", price) }
  def self.search_by_name(query, limit: 5)
    normalized = I18n.transliterate(query.downcase)
    all.select { |t| I18n.transliterate(t.name.downcase).include?(normalized) }.first(limit)
  end
  scope :by_names, ->(names) { where(name: names) }

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

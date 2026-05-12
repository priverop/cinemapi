# frozen_string_literals: true

puts 'BEGIN SEEDING:'

puts 'Removing old stuff:'
puts '- - - - - - - - - -'
Showtime.destroy_all
Movie.destroy_all
Theater.destroy_all
Session.destroy_all
User.destroy_all

puts 'Creating Theaters'
puts '- - - - - - - - - -'
Theater.create!(name: 'Renoir Retiro', location: 'Calle Narváez 42, Madrid', price: 8.5, discounted_price: 5.5, discounted_days: [ 'monday', 'wednesday' ], website: "https://www.cinesrenoir.com/cine/renoir-retiro/cartelera/", scraper_key: 1)
Theater.create!(name: 'Renoir Floridablanca', location: 'Calle Floridablanca 135, Barcelona', price: 8.5, discounted_price: 5.5, discounted_days: [ 'monday', 'wednesday' ], website: "https://www.cinesrenoir.com/cine/renoir-floridablanca/cartelera/", scraper_key: 1)
Theater.create!(name: 'Cinesa Príncipe Pío', location: 'Centro Comercial Principe Pío, Madrid', price: 11.5, discounted_price: 6.5, discounted_days: [ 'wednesday' ], website: "https://www.cinesa.es/cines/principe-pio/", scraper_key: 2, scraper_external_id: "027")

puts 'Creating Users'
puts '- - - - - - - - - -'
if Rails.env.development?
  User.create!(email_address: "admin@cinemapi.com", password: "123")
else
  admin_email = ENV.fetch("ADMIN_EMAIL")
  admin_password = ENV.fetch("ADMIN_PASSWORD")
  User.create!(email_address: admin_email, password: admin_password)
end

puts 'SUCCESS!'

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
Theater.create!(name: 'Renoir Princesa', location: 'Plaza de los Cubos, Madrid', price: 8.5, discounted_price: 5.5, discounted_days: [ 'monday', 'wednesday' ], website: "https://www.cinesrenoir.com/cine/cines-princesa/cartelera/", scraper_key: 1)
Theater.create!(name: 'Renoir Plaza España', location: 'Calle Martín de los Heros, Madrid', price: 8.5, discounted_price: 5.5, discounted_days: [ 'monday', 'wednesday' ], website: "https://www.cinesrenoir.com/cine/renoir-plaza-de-espana/cartelera/", scraper_key: 1)
Theater.create!(name: 'Renoir Retiro', location: 'Calle Narváez 42, Madrid', price: 8.5, discounted_price: 5.5, discounted_days: [ 'monday', 'wednesday' ], website: "https://www.cinesrenoir.com/cine/renoir-retiro/cartelera/", scraper_key: 1)
Theater.create!(name: 'Renoir Floridablanca', location: 'Calle Floridablanca 135, Barcelona', price: 8.5, discounted_price: 5.5, discounted_days: [ 'monday', 'wednesday' ], website: "https://www.cinesrenoir.com/cine/renoir-floridablanca/cartelera/", scraper_key: 1)
Theater.create!(name: 'Cinesa Príncipe Pío', location: 'Centro Comercial Principe Pío, Madrid', price: 11.5, discounted_price: 6.5, discounted_days: [ 'wednesday' ], website: "https://www.cinesa.es/cines/principe-pio/", scraper_key: 2, scraper_external_id: "027")
Theater.create!(name: 'mk2 Cine Paz', location: 'Calle de Fuencarral 125, Madrid', price: 10.9, discounted_price: 8, discounted_days: [ 'wednesday' ], website: "https://www.cinepazmadrid.es/es/cartelera", scraper_key: 3)
Theater.create!(name: 'mk2 Palacio de Hielo', location: 'Calle Silvano 77, Madrid', price: 10.9, discounted_price: 8, discounted_days: [ 'wednesday' ], website: "https://www.mk2palaciodehielo.es/es/cartelera", scraper_key: 3)
Theater.create!(name: 'Embajadores Sta María', location: 'Gta. Sta. Mª de la Cabeza 5, Madrid', price: 9.5, discounted_price: 5.9, discounted_days: [ 'monday', 'wednesday' ], website: "https://cinesembajadores.es/madrid/", scraper_key: 4)
Theater.create!(name: 'Embajadores Río', location: 'Calle Ercilla 53, Madrid', price: 9.5, discounted_price: 5.9, discounted_days: [ 'monday', 'wednesday' ], website: "https://cinesembajadores.es/madrid/", scraper_key: 5)
Theater.create!(name: 'Verdi Madrid', location: 'Calle de Bravo Murillo, 28, Madrid', price: 8.5, discounted_price: 5.9, discounted_days: [ 'monday' ], website: "https://madrid.cines-verdi.com/cartelera", scraper_key: 7)
Theater.create!(name: 'Cinemes Girona', location: 'Carrer de Girona, 175, Barcelona', price: 7, discounted_price: 5, discounted_days: [ 'wednesday' ], website: "https://www.cinemesgirona.cat/es/cartelera", scraper_key: 7)
Theater.create!(name: 'Zumzeig', location: 'Carrer Béiar, 53, Barcelona', price: 7.5, discounted_price: 5.5, discounted_days: [ 'wednesday' ], website: "https://zumzeigcine.coop/es/", scraper_key: 8)

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

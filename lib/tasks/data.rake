require 'open-uri'
require 'json'
require 'yaml'
require 'colorize'

namespace :data do

  desc "Import embassies from the Foreign & Commonwealth Office API"
  task :embassies do
    filename = Rails.root.join('lib','data','embassies.json')
    api_endpoint = 'http://fco.innovate.direct.gov.uk/countries.json'

    puts "Importing embassies from #{api_endpoint}...".colorize( :white )

    countries = JSON.parse( open(api_endpoint).read ).each_with_object({}) do |country, h|
      puts "#{country['country']['name']} (#{country['country']['slug']}) has #{country['country']['embassies'].size} #{country['country']['embassies'].size == 1 ? "embassy" : "embassies"}".colorize( :cyan )
      h[country['country']['slug']] = country['country']['embassies'].map do |embassy|
        {
          :address => embassy['address']['plain'],
          :designation => embassy['designation'],
          :lat => embassy['lat'],
          :lon => embassy['long'],
          :location_name => embassy['location_name'],
          :phone => embassy['phone']
        }
      end
    end

    puts "Writing data to #{filename}...".colorize( :white )

    File.open(filename, 'w') do |f|
      f.write(countries.to_json)
    end

    puts "Embassy import complete".colorize( :green )    
  end
end


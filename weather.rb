require 'net/http'
require 'json'

url = "http://api.openweathermap.org/data/2.5/weather?q=#{ARGV[0]}&units=metric&lang=bg"

data = Net::HTTP.get_response(URI(url))
h = JSON.parse(data.body)
r = h['weather'][0]['description'] + "\s" + h['main']['temp'].round.to_s + "\sC"

puts r


require 'net/http'
require 'json'

appid = 'bd82977b86bf27fb59a04b61b657fb6f'

url = "http://api.openweathermap.org/data/2.5/weather?q=#{ARGV[0]}&units=metric&lang=bg&appid=#{appid}"

data = Net::HTTP.get_response(URI(url))
h = JSON.parse(data.body)
r = h['weather'][0]['description'] + "\s" + h['main']['temp'].round.to_s + "\sC"

puts r


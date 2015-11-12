require 'open-uri'
require 'json'

def get_appid(fetch = false)
  appid_file = '.appid'
  if fetch
    appid = open('http://openweathermap.org/').read.match(/appid=(\h+)/)[1]
    File.write(appid_file, appid)
    return appid
  else
    if File.exist?(appid_file)
      return File.read(appid_file)
    else
      get_appid(true)
    end
  end
end

try_once = true
begin
  url = "http://api.openweathermap.org/data/2.5/weather?q=#{ARGV[0]}&units=metric&lang=bg&appid=#{get_appid}"
  h = JSON.parse(open(url).read)
  r = h['weather'][0]['description'] + "\s" + h['main']['temp'].round.to_s + "\sC"
  puts r
rescue Exception => e
  get_appid(true)
  if try_once
    try_once = false
    retry
  else
    puts e.to_s
  end
end


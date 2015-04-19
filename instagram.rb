require 'open-uri'
require 'json'

def get_photos(username)
  url = 'https://instagram.com/' + username + '/media/'
  photos = []
  loop do
    json = JSON.parse(open(url).read)
    photos += json['items'].map{ |p| p['images']['standard_resolution']['url'] }
    url = 'https://instagram.com/' + username + '/media/?max_id=' + json['items'].last['id']
    break unless json['more_available']
  end
  return photos
end


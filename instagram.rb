require 'open-uri'
require 'json'

def get_photos(username)
  url = 'https://instagram.com/' + username + '/media/'
  photos = []
  loop do
    json = JSON.parse(open(url).read)
    photos += json['items'].map{ |p| p['images']['standard_resolution']['url'] }
    url = 'https://instagram.com/' + username + '/media/?max_id=' + json['items'].last['id'].split('_').first
    break unless json['more_available']
  end
  return photos
end

def get_sharedData(username)
  JSON.parse(open("https://www.instagram.com/#{username}/")
             .read[/<script type="text\/javascript">window._sharedData = (.*?);<\/script>/, 1])
end

def get_profile_pic(username)
  open("https://www.instagram.com/#{username}/")
  .read[/<meta property="og:image" content="(.*?)" \/>/, 1]
  .sub('/s150x150', '')
end

def get_media(username)
  url = "https://instagram.com/#{username}/media/"
  medias = []
  loop do
    json = JSON.parse(open(url).read)
    medias.push json
    break if json['items'].empty?
    url = "https://instagram.com/#{username}/media/?max_id=#{json['items'].last['id'].split('_').first}"
    break unless json['more_available']
  end
  return JSON.fast_generate(medias)
end


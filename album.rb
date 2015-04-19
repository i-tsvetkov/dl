# encoding: utf-8
require 'open-uri'

def get_photos(username, pages)
  photos = []
  (1 .. pages).each do |i|
    url = 'http://www.album.bg/' + username + '/?view=4&page=' + i.to_s
    html = open(url).read
    photos += html.scan(/Размер на оригинала: <a target='_blank' href='([^']+)'>/).flatten
  end
  return photos
end


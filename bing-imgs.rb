require 'open-uri'
require 'json'

def bing_imgs(imgs)
  case imgs
  when :today
    idx, n =  0, 1
  when :all
    idx, n = 25, 4
  else
    return []
  end
  url  = "https://www.bing.com/HPImageArchive.aspx?format=js&idx=#{idx}&n=#{n}"
  json = JSON.parse(open(url).read)
  json['images'].map{ |i| "https://www.bing.com#{i['url']}" }
end


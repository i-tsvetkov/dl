require 'open-uri'
require 'json'

module Imgur
  def Imgur.get_json(gallery, sort = :hot, page = 0)
    JSON.parse(open("https://imgur.com/#{gallery}/#{sort}/page/#{page}.json").read)
  end
end


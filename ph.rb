require 'open-uri'

def get_recommended
  open('http://www.pornhub.com/recommended').read
  .scan(/^\s*<a href="\/view_video\.php\?viewkey=(.*?)" title="(.*?)">/)
  .map { |key, title| { key: key, title: title } }
end


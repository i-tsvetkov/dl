require 'open-uri'

def get_videos(username)
  # youtube api sucks
  open("https://www.youtube.com/user/#{username}/videos").read
  .scan(/<h3 class="yt-lockup-title ">.*?title="(.*?)".*?href="\/watch\?v=(.*?)"/)
  .map { |title, id| { title: title, id: id } }
end


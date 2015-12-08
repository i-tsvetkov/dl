require 'open-uri'
require 'json'

module Reddit
  def Reddit.get_json(subreddit, sort = :hot)
    JSON.parse(open("https://www.reddit.com/r/#{subreddit}/#{sort}.json").read)
  end
end


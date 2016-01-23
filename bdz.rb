require 'open-uri'

def bdz(url)
  html = open(url).read
  items = html.scan(/<span class="style13">(.+?)<\/span>/).flatten
  return nil unless items.size.modulo(3).zero?
  get_time = ->(time) { time.eql?('--') ? :none : time }
  items.each_slice(3).map do |station, leave_time, arrive_time|
    {
      city: station,
      leave: get_time[leave_time],
      arrive: get_time[arrive_time]
    }
  end
end


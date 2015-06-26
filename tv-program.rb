require 'open-uri'

def tv(channel)
  case channel.to_sym
  when :nova
    return open('http://novatv.bg/schedule/listview').read
          .scan(/<div class="programme_time">([^<]+)<\/div>\s*<a href="[^"]+" class="programme_title">([^<]+)<\/a>/m)
          .map { |time, show| "#{time.strip}\s-\s#{show.strip}" }
          .join("\n")
  when :btv
    return open('http://www.btv.bg/programata/').read
          .match(/<ul class="listing chanel_1">.*?<\/ul>/m).to_s
          .scan(/<span class="(?:time|title)">([^<]+)<\/span>/)
          .flatten
          .each_slice(2)
          .map { |time, show| "#{time}\s#{show}" }
          .join("\n")
  when :bnt
    days = ['ponedelnik', 'vtornik', 'srqda', 'chetvurtuk', 'petuk', 'subota', 'nedelq']
    return open('http://bnt.bg/programata').read
          .match(/<li class="programDays" id="#{days[Time.now.wday - 1]}_one">.*?<\/li>/m).to_s
          .scan(/<div class="programInnerHourTime">([^<]+)<\/div>\s*<div class="programInnerNameInfo"><a href="[^"]+" class="programInnerProdName">([^<]+)<\/a>/m)
          .map { |time, show| "#{time}\s-\s#{show}" }
          .join("\n")
  else
    return ''
  end
end

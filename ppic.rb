require 'open-uri'
require 'digest/sha1'
require 'sqlite3'
require 'yaml'
require 'json'

unless File.exist?('pictures.db')
  db = SQLite3::Database.new('pictures.db')
  db.execute('CREATE TABLE pictures('\
             'id   CHAR(40) PRIMARY KEY NOT NULL,'\
             'user TEXT    NOT NULL,'\
             'data TEXT    NOT NULL,'\
             'time INTEGER NOT NULL)')
end

db  ||= SQLite3::Database.new('pictures.db')
ids   = db.execute('SELECT id FROM pictures').flatten(1)
users = YAML.load(File.read('config.yaml'))['users']

def get_url(user_id)
  w = h = 10 ** 5 - 1
  "https://graph.facebook.com/#{user_id}/picture?width=#{w}&height=#{h}&redirect=false"
end

def sleep_time(n)
  rand(16 * 60 .. 26 * 60) / n
end

loop do
  users.shuffle.each do |user|
    puts "[#{Time.now.strftime('%H:%M')}]\sfetch\s\e[1;34m#{user['name']}\e[m\s..."
    data = open(get_url(user['id'])).read
    id   = Digest::SHA1.hexdigest(data)
    unless ids.include?(id)
      ids.push(id)
      json = JSON.load(data)
      name = user['name']
      id, user, data, time = SQLite3::Database.quote(id),
                             SQLite3::Database.quote(user['id']),
                             SQLite3::Database.quote(data),
                             Time.now.to_i
      db.execute("INSERT INTO pictures "\
                 "VALUES ('#{id}', '#{user}', '#{data}', #{time})")
      puts "\e[1;31mnew\e[m\e[1;37m('#{id}', '#{name}', '#{data}', #{time})\e[m"
      system("curl -sL 'https://graph.facebook.com/#{user}/picture' > '#{id}.jpg'")
      url, w, h = json['data']['url'], json['data']['width'].to_i, json['data']['height'].to_i
      system("notify-send -i '#{Dir.pwd}/#{id}.jpg' '#{name}\s(#{w}\sx\s#{h})' '#{url}'")
    end
    sleep sleep_time(users.size)
  end
end


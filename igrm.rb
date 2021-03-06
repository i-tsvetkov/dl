require 'open-uri'
require 'digest/sha1'
require 'sqlite3'
require 'yaml'
require 'json'
require './instagram.rb'
require_relative 'json-diff.rb'
require_relative 'mail2sms.rb'

class Igrm
  def initialize(database_name, config = 'config.yaml')
    unless File.exist?(database_name)
      @db = SQLite3::Database.new(database_name)
      @db.execute(['CREATE TABLE media(',
                   'id      CHAR(40) PRIMARY KEY NOT NULL,',
                   'user    TEXT    NOT NULL,',
                   'media   TEXT    NOT NULL,',
                   'time    INTEGER NOT NULL)'].join("\n\t"))
      @db.execute(['CREATE TABLE pictures(',
                   'id      CHAR(40) PRIMARY KEY NOT NULL,',
                   'user    TEXT    NOT NULL,',
                   'picture TEXT    NOT NULL,',
                   'time    INTEGER NOT NULL)'].join("\n\t"))
      @db.execute(['CREATE TABLE data(',
                   'id      CHAR(40) PRIMARY KEY NOT NULL,',
                   'user    TEXT    NOT NULL,',
                   'data    TEXT    NOT NULL,',
                   'time    INTEGER NOT NULL)'].join("\n\t"))
    end

    @yaml = YAML.load_file(config)
    @db ||= SQLite3::Database.new(database_name)
    @users = @yaml['users']
    @sleep_range  = eval @yaml['sleep'][/\d+\s*\.\.\.?\s*\d+/].to_s
    @data_ids     = @db.execute('SELECT id FROM data').flatten(1)
    @media_ids    = @db.execute('SELECT id FROM media').flatten(1)
    @pictures_ids = @db.execute('SELECT id FROM pictures').flatten(1)

    system('mkdir -p pics')
    system('mkdir -p profile_pic')
  end

  def start
    loop do
      @users.shuffle.each do |user|
        check(user)
        get_sleep
      end
    end
  end

  private

  def check(user)
    @current_user = user
    puts "fetching #{@current_user}"
    media   = get_media(user)
    data    = JSON.fast_generate(get_sharedData(user)['entry_data'])
    picture = get_profile_pic(user)

    media_id   = Digest::SHA1.hexdigest(user + media)
    data_id    = Digest::SHA1.hexdigest(user + data)
    picture_id = Digest::SHA1.hexdigest(user + picture)

    log(:media, media)      unless @media_ids.include? media_id
    log(:data, data)        unless @data_ids.include? data_id
    log(:pictures, picture) unless @pictures_ids.include? picture_id
  end

  def get_sleep
    col = ENV['COLUMNS'].to_i
    time = rand(@sleep_range).to_f * 60 / @users.size / col
    col.times { print('.'); sleep(time) }
    printf("\r%*s\r", col, '')
  end

  def get_user_pic(user)
    "#{Dir.pwd}/profile_pic/#{user}.jpg"
  end

  def sms_notify(text)
    mail2sms(@yaml['sms']['guser'],
             @yaml['sms']['gpass'],
             @yaml['sms']['phone'],
             text) unless @yaml['sms'].nil?
  end

  def normal_notify(value)
    puts "#{@current_user}:\s#{value}"[0, ENV['COLUMNS'].to_i]
    system("notify-send -i '#{get_user_pic(@current_user)}' '#{@current_user}' '#{value}'")
    sms_notify("#{@current_user}:#{value}")
  end

  def beep
    system 'paplay /usr/share/sounds/freedesktop/stereo/bell.oga'
  end

  def notify(value, table)
    beep
    case table
    when :pictures
      puts "#{@current_user}:\s#{value}"
      timestamp = Time.now.to_i
      filename  = "#{timestamp}_#{value.split('/').last}"
      system("wget -q -O 'pics/#{filename}' '#{value}'")
      system("curl -s '#{value}' > 'profile_pic/#{@current_user}.jpg'")
      system("notify-send -i '#{Dir.pwd}/pics/#{filename}' '#{@current_user}' '#{value}'")
      sms_notify("#{@current_user}:#{value}")
    when :data
      new, old = @db.execute(["SELECT data FROM data",
                              "WHERE user = '#{@current_user}'",
                              "ORDER BY time DESC",
                              "LIMIT 2"].join("\n\t")).flatten
      if old.nil?
        normal_notify(value)
      else
        diff = json_diff(JSON.parse(new), JSON.parse(old)).map do |it|
          ["#{it[:type]}#{it[:path]}:", [it[:value]].flatten.reverse.join("\s\u2192\s")]
        end
        puts (["#{@current_user}:"] + diff).join("\n\t")
        system("notify-send -i '#{get_user_pic(@current_user)}' '#{@current_user}' '#{diff.join("\n")}'")
        sms_notify(diff.join("\s").gsub("\s\u2192\s", '/').prepend("#{@current_user}:"))
      end
    else
      normal_notify(value)
    end
  end

  def log(table, value)
    id = Digest::SHA1.hexdigest(@current_user + value)
    id, user, value, time = SQLite3::Database.quote(id),
                            SQLite3::Database.quote(@current_user),
                            SQLite3::Database.quote(value),
                            Time.now.to_i
    @db.execute("INSERT INTO #{table} "\
                "VALUES ('#{id}', '#{user}', '#{value}', #{time})")

    eval "@#{table}_ids.push id"

    notify(value, table)
  end
end


require 'open-uri'
require 'digest/sha1'
require 'sqlite3'
require 'yaml'
require 'json'
require './instagram.rb'

class Igrm
  def initialize(database_name)
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
    @db ||= SQLite3::Database.new(database_name)
    @users = YAML.load(File.read('config.yaml'))['users']
    @data_ids    = @db.execute('SELECT id FROM data').flatten(1)
    @media_ids   = @db.execute('SELECT id FROM media').flatten(1)
    @pictures_ids = @db.execute('SELECT id FROM pictures').flatten(1)
  end

  def start
    loop do
      @users.each do |user|
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

  SLEEP_RANGE = 1..1

  def get_sleep
    sleep(rand(SLEEP_RANGE) * 60 / @users.size)
  end

  def notify(value, picture = false)
    if picture
      puts "#{@current_user}:\s#{value}"
      system("wget -qP pics '#{value}'")
      system("notify-send -i '#{Dir.pwd}/pics/#{value.split('/').last}' '#{@current_user}' '#{value}'")
    else
      puts "#{@current_user}:\s#{value[0 .. 80]}..."
      system("notify-send '#{@current_user}' '#{value}'")
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

    notify(value, table == :pictures)
  end
end


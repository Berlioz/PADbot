require 'cinch'
require 'pry'
require 'data_mapper'
require 'json'
require './dispatcher.rb'
require './plugins/base.rb'
Dir.glob("plugins/*.rb").each {|x| require_relative x}
Dir.glob("models/*.rb").each {|x| require_relative x}

def initialize_database
  config = JSON.parse(File.read("database_config.json"))
  DataMapper.setup(:default, config)
  DataMapper.finalize
end

def initialize_cinch
  Cinch::Bot.new do
    configure do |c|
      c.server = "irc.synirc.net"
      c.nick = "asterbot-kai"
      c.channels = [ "#asterbottest"]
      c.plugins.plugins = [Dispatcher]
    end
  end
end

initialize_database
bot = initialize_cinch
bot.start

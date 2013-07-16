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
  config = JSON.parse(File.read("irc_config.json"))
  Cinch::Bot.new do
    configure do |c|
      c.server = config["server"]
      c.nick = config["nick"]
      c.channels = config["channels"]
      c.plugins.plugins = [Dispatcher]
    end
  end
end

initialize_database
bot = initialize_cinch
bot.start

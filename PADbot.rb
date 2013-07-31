require 'cinch'
require 'pry'
require 'data_mapper'
require 'json'
require 'yaml'
require './dispatcher.rb'
require './plugins/base.rb'
Dir.glob("plugins/*.rb").each {|x| require_relative x}
Dir.glob("models/*.rb").each {|x| require_relative x}

def initialize_database
  config = JSON.parse(File.read("database_config.json"))
  DataMapper.setup(:default, config)
  DataMapper.finalize
end

def initialize_cinch_bots(environment)
  config = YAML.load(File.read("irc_config.yaml"))
  selected_config = config[environment]
  selected_config.map do |server_config|
    Cinch::Bot.new do
      configure do |c|
        c.server = server_config["server"]
        c.nick = server_config["nick"]
        c.channels = server_config["channels"]
        c.plugins.plugins = [Dispatcher]
      end
    end
  end
end

environment = ARGV.first || 'development'
initialize_database
bots = initialize_cinch_bots(environment)
workers = bots.map do |bot|
  Thread.new do
    bot.start
  end
end
workers.each do |thread|
  thread.join
end 

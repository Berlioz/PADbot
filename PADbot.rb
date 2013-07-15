require 'cinch'
require 'pry'
require 'data_mapper'
require './dispatcher.rb'
require './plugins/base.rb'
Dir.glob("plugins/*.rb").each {|x| require_relative x}
Dir.glob("models/*.rb").each {|x| require_relative x}

def initialize_database
  DataMapper.setup(:default, {
    :adapter => 'postgres',
    :host => 'localhost',
    :database => 'pazudora',
    :user => 'victor',
    :password => 'wtfpostgres'
  })
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

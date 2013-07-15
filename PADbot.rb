require 'cinch'
require 'pry'
require './dispatcher.rb'
require './plugins/base.rb'
Dir.glob("plugins/*.rb").each {|x| require_relative x}

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

bot = initialize_cinch
bot.start

require 'cinch'
require 'singleton'
require 'time'

class PazudoraPluginBase
  include Singleton
  @@commands = {}
  @@dispatcher = nil
  
  def self.descendants
    ObjectSpace.each_object(Class).select {|klass| klass < self}
  end

  def self.helpstring
    "No helpstring for #{self.name}. It might be documented on https://github.com/Berlioz/PADbot"
  end

  def self.aliases
    []
  end
     
  def self.dispatch(command, opts={})
    @@commands[command.to_sym] = opts[:to].to_sym if opts[:to]
  end

  def self.set_dispatcher(dispatcher)
    @@dispatcher = dispatcher
  end

  def respond(m, args)
    #m.params = ["#csuatest", "!stupidpuzzledragonbullshit command and args"]
    command = m.params.last.split[1].to_sym
    if @@commands[command]
      send(@@commands[command].to_sym, m, args)
    else
      raise NotImplementedError.new("You must implement #{__method__}")
    end
  end

  def registered_users
    User.registered_with_plugin(self.class)
  end

  def with_authorized_irc_handle(m, args, &block)
    caller = User.fuzzy_search(m.user.nick)
    unless caller.is_admin
      m.reply "You are not authorized to call this subroutine." && return
    end
    yield(m, args)
  end

  def reply_on_bad_syntax(m)
    m.reply "Unknown syntax. Try !pad help #{self.class.aliases.first}."
  end

  private

  def log_spending(amount)
    logfile = File.open("stones.txt", "a")
    logfile.puts "#{Time.now.utc.iso8601} #{amount}"
    logfile.close
  end
end

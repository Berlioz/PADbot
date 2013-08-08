require 'cinch'
require 'singleton'

class PazudoraPluginBase
  include Singleton
  @@commands = {}
  
  def self.descendants
    ObjectSpace.each_object(Class).select {|klass| klass < self}
  end

  def self.helpstring
    "No HELP information defined for #{self.name}. Bug Asterism about it."
  end

  def self.aliases
    []
  end
     
  def self.dispatch(command, opts={})
    @@commands[command.to_sym] = opts[:to].to_sym if opts[:to]
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
end

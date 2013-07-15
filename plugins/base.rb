require 'cinch'
require 'singleton'

class PazudoraPluginBase
  include Singleton

  def self.descendants
    ObjectSpace.each_object(Class).select {|klass| klass < self}
  end

  def self.helpstring
    "No HELP information defined for #{self.name}. Bug Asterism about it."
  end

  def self.aliases
    []
  end

  def respond(m, args)
    raise NotImplementedError.new("You must implement #{__method__}")
  end
end

require 'cinch'
require 'singleton'

class PazudoraPluginBase
  include Singleton

  def self.descendants
    ObjectSpace.each_object(Class).select {|klass| klass < self}
  end

  def self.helpstring
"Computes an arbitrary mathematical expression in ruby, with sanitation.
Example: !pad calc 0.8 ** 5 for your odds of getting screwed on a 5 skillup feed."
  end

  def self.aliases
    []
  end

  def respond(m, args)
    raise NotImplementedError.new("You must implement #{__method__}")
  end
end

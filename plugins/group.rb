class GroupPlugin < PazudoraPluginBase
  def self.helpstring
    "No HELP information defined for #{self.name}. Bug Asterism about it."
  end

  def self.aliases
    ['group']
  end

  def respond(m, args)
    m.reply "#{self.name} has not yet been ported from Asterbot 1.0"
  end
end

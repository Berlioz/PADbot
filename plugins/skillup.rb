class SkillupPlugin < PazudoraPluginBase
  def self.helpstring
    "No HELP information defined for #{self.name}. Bug Asterism about it."
  end

  def self.aliases
    ['skillup', 'bino', 'cdf', 'binomial']
  end

  def respond(m, args)
    m.reply "#{self.name} has not yet been ported from Asterbot 1.0"
  end
end

class EchoPlugin < PazudoraPluginBase
  def self.aliases
    ['echo']
  end

  def self.helpstring
    ""
  end

  def respond(m, args)
    p "*****"
    p m.channel
  end

end

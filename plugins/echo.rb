class EchoPlugin < PazudoraPluginBase
  def self.aliases
    ['echo']
  end

  def self.helpstring
    ""
  end

  def respond(m, args)
    challenge = File.open("admin", "r").read
    p challenge
    channel, password, message = args.split(' ', 3)
    return if password != challenge
    
    @@dispatcher.exec_helper("Channel", channel).send(message)
  end

end

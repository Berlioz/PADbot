class PadherderPlugin < PazudoraPluginBase
  def self.aliases
    ['herder', 'herd', 'freddie']
  end

  def self.helpstring
    "!pad herder: echoes a Padherder profile page URI, assuming that your PH name == your IRC handle
    !pad herder NAME: echoes a Padherder profile page URI for the given user"
  end

  def respond(m, args)
    if args.length > 0
      username = args
    else
      username = m.user.nick
    end
    
    m.reply "https://www.padherder.com/user/#{username}/monsters"
  end

end

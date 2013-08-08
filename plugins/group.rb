class GroupPlugin < PazudoraPluginBase
  def self.helpstring
    "No HELP information defined for #{self.name}. Bug Asterism about it."
  end

  def self.aliases
    ['group']
  end

  def respond(m,args)
    username = args.strip
    user = User.fuzzy_lookup(username)
    if user.nil?
      m.reply "Unknown user/IRC alias #{username}."
    else
      m.reply "#{user.registered_name}'s group is #{user.group}"
    end
  end
end

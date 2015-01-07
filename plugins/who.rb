class WhoPlugin < PazudoraPluginBase
  def self.aliases
    ['who', 'code', 'fc', 'padherder','herder','freddie']
  end

  def self.helpstring
    "!pad lookup USERNAME: Displays the provider user's PAD friend code. Searches by registered IRC handles."
  end

  def respond(m,args)
    username = args ? args.strip : m.user.nick
    user = User.fuzzy_lookup(username)
    if user.nil?
      m.reply "Unknown user/IRC alias #{username}."
    else
      m.reply "#{user.registered_name}'s code is #{user.pad_code}"
	unless user.padherder_name.nil?
		m.reply "#{user.registered_name}'s padherder page is https://www.padherder.com/user/#{user.padherder_name}"
	end
    end
  end
end

class AllPlugin < PazudoraPluginBase

end

class DeletePlugin < PazudoraPluginBase

end

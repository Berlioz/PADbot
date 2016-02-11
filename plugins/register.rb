class RegisterPlugin < PazudoraPluginBase
  def self.aliases
    ['register', 'add']
  end

  def self.helpstring
"!pad register USERNAME FC [PADHERDER-USERNAME?]: creates an account (!pad register asterbot 123456789 asterbot)
!pad register alias USERNAME: registers your current IRC handle to the already registered USERNAME
!pad register padherder PADHERDER-USERNAME: registers your padherder username to an existing account."
  end

  def respond(m,args)
    argv = args.split(" ")
    if argv.first == "alias"
      add_user_alias(m, argv.last, m.user.nick)	
    elsif argv.first == "padherder"
      add_user_padherder(m, m.user.nick, argv.last)
    elsif argv.length == 1
      add_user(m, m.user.nick, argv.first)
    elsif argv.length == 2
      add_user(m, argv.first, argv.last)
    elsif argv.length == 3
      add_user(m, argv.first, argv[1], argv[2])
    else
      reply_on_bad_syntax(m)
    end
  end

  def add_user(m, username, fc, padherder_name=nil)
    duplicate_user = User.fuzzy_lookup(username)
    if duplicate_user
      m.reply "#{username} seems to be associated with an existing user #{duplicate_user}." and return
    end
    sanitized_fc = fc.gsub(/[^0-9]/,"").to_i
    unless sanitized_fc.to_s.length == 9
      m.reply "ERROR: provided FC is not 9 digits long. Aborting." and return
    end
    User.create(
      :registered_name => username,
      :irc_aliases => [],
      :pad_code => sanitized_fc,
      :is_admin => false,
      :plugin_registrations => [],
      :padherder_name => padherder_name
    )
   m.reply "Created #{username} with FC #{sanitized_fc}."
   unless padherder_name.nil?
	m.reply "#{username}'s padherder page is https://www.padherder.com/user/#{padherder_name}"
   end
  end

  def add_user_alias(m, username, new_alias)
    original_user = User.fuzzy_lookup(username)
    unless original_user
      m.reply "#{username} does not match a known existing user." and return
    end
    original_user.irc_aliases = original_user.irc_aliases + [new_alias]
    original_user.save
    m.reply "Associated #{original_user} with new alias #{new_alias}."
  end

  def add_user_padherder(m, username, padherder_name)
	original_user = User.fuzzy_lookup(username)
	unless original_user
		m.reply "#{username} does not match a known existing user." and return
	end
	original_user.padherder_name = padherder_name
	original_user.save
	m.reply "Associated #{original_user} with padherder username #{padherder_name}."
	m.reply "#{original_user}'s padherder page is 'https://www.padherder.com/user/#{padherder_name}'."
  end
end

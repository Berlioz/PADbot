class RegisterPlugin < PazudoraPluginBase
  def self.aliases
    ['register', 'add']
  end

  def self.helpstring
"!pad register USERNAME FC PADHERDER-USERNAME: Tells asterbot to associate USERNAME with the provided FC (!pad register asterbot 123456789 asterbot)
Note that the PADHERDER-USERNAME is optional if you don't have a padherder account (but why wouldn't you?)
!pad register FC: Tells asterbot to associate your current IRC handle with the provided FC.
!pad register alias USERNAME: Tells asterbot that your current IRC handle belongs to the already registered USERNAME
Yes, this means if your username is alias you're SOL. Whoops.
!pad register padherder PADHERDER-USERNAME: Tells asterbot to register your padherder username so we can easily get a link."
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
    if padherder_name==nil
    User.create(
      :registered_name => username,
      :irc_aliases => [],
      :pad_code => sanitized_fc,
      :is_admin => false,
      :plugin_registrations => []
    )
   m.reply "Created #{username} with FC #{sanitized_fc}."

    else
    User.create(
      :registered_name => username,
      :irc_aliases => [],
      :pad_code => sanitized_fc,
      :is_admin => false,
      :plugin_registrations => [],
      :padherder_name => padherder_name
    )
    m.reply "Created #{username} with FC #{sanitized_fc}."
    m.reply "#{username}'s padherder link is 'https://www.padherder.com/user/#{padherder_name}/monsters/'."
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
	m.reply "#{original_user}'s padherder link is 'https://www.padherder.com/user/#{padherder_name}/monsters/'."
  end
end

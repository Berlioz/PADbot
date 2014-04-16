class RegisterPlugin < PazudoraPluginBase
  def self.aliases
    ['register', 'add']
  end

  def self.helpstring
"!pad register USERNAME FC: Tells asterbot to associate USERNAME with the provided FC (!pad register asterbot 123456789)
!pad register FC: Tells asterbot to associate your current IRC handle with the provided FC.
!pad register alias USERNAME: Tells asterbot that your current IRC handle belongs to the already registerd USERNAME
Yes, this means if your username is alias you're SOL. Whoops."
  end

  def respond(m,args)
    argv = args.split(" ")
    if argv.first == "alias"
      add_user_alias(m, argv.last, m.user.nick)
    elsif argv.length == 1
      add_user(m, m.user.nick, argv.first)
    elsif argv.length == 2
      add_user(m, argv.first, argv.last)
    else
      reply_on_bad_syntax(m)
    end
  end

  def add_user(m, username, fc)
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
      :plugin_registrations => []
    )
    m.reply "Created #{username} with FC #{sanitized_fc}."
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
end

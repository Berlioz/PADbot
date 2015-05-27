class HelpPlugin < PazudoraPluginBase
  def self.aliases
    ['help']
  end

  def self.helpstring
    "!pad help COMMAND: are you fucking kidding me"
  end

  def respond(m,args)
    if args.nil?
      display_known_plugins(m)
    else
      display_helpstring(m, args)
    end
  end

  def display_known_plugins(m)
    plugins = PazudoraPluginBase.descendants
    names = plugins.map{|p| p.aliases.first}
    names = names.compact
    msg = "Asterbot command documentation at https://github.com/Berlioz/PADbot"
    msg += "\nKnown plugins (!pad HELP plugin for in-channel help): " + names.join(", ")
    m.reply msg
  end

  def display_helpstring(m, args)
    plugin_name = args.downcase.chomp
    plugins = PazudoraPluginBase.descendants
    plugin = plugins.select{|p| p.aliases.include?(plugin_name)}.first
    if plugin.nil?
      m.reply "Unknown command #{plugin_name}. For a list of all known commands, !pad help"
    else
      m.reply plugin.helpstring
    end
  end
end

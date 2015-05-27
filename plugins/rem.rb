class RemPlugin < PazudoraPluginBase
  def self.aliases
    ["rem"]
  end

  def self.helpstring
    "!pad rem SEARCHKEY: Returns information on what Asterbot thinks the monster's REM status is"
  end

  def rem_status(m)
    if m.pantheon
      "is part of a godfest pantheon, with the tag #{m.pantheon}"
    elsif m.rem?
      "is available from the NA REM, but is not included in standard godfests"
    else
      "is not available from the NA REM at this time"
    end
  end

  def respond(m, args)
    puzzlemon = Monster.fuzzy_search(args)
    m.reply "Could not find monster #{args}" && return if puzzlemon.nil?
    m.reply "I believe that #{puzzlemon.name} #{rem_status(puzzlemon)}"
  end
end
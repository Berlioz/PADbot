class SkillMatchPlugin < PazudoraPluginBase
  def self.aliases
    ["skill", "skillmatch"]
  end

  def self.helpstring
    "!pad skill MONSTER: lists all monsters that have the same active skill as MONSTER."
  end

  def respond(m, args)
    puzzlemon = Monster.fuzzy_search(args)
    m.reply "Could not find monster #{args}" && return if puzzlemon.nil?
    m.reply "##{puzzlemon.id} #{puzzlemon.name} has no active skill..." && return if puzzlemon.skill_text.nil?
    matches = Monster.all.select{|m| m.skill_text == puzzlemon.skill_text && m.id != puzzlemon.id}

    matches = matches.select{|m| !m.unevolved || Monster.get(m.unevolved).skill_text != m.skill_text}

    if matches.length > 0
      skillname = puzzlemon.skill_text.split(':').first.split(') ').last
      m.reply("Matches for #{skillname}: " + matches.map{|m| "##{m.id} #{m.name}"}.join('; '))
    else
      m.reply("No matches found.")
    end
  end
end

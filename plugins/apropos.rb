class AproposPlugin < PazudoraPluginBase
  def self.aliases
    ["disambiguate", "which"]
  end

  def self.helpstring
"!pad which [NAME]: Returns a set of all monster names which contain NAME as a substring."
  end

  def respond(m, args)
    matches = substring_search(args)
    if matches.length > 8
      m.reply("More than 8 results were found; please narrow your query.")
    elsif matches.length == 0
      m.reply("No matches found for substring '#{args}'")
    else
      r = "Matches found: " + matches.map{|monster| format(monster)}.join(", ")
    end
  end

  def format(monster)
    "##{monster.id} #{monster.name}" + (monster.stars ? " (#{monster.stars}*)" : "")
  end

  def substring_search(identifier)
    Monster.all.select{|m| m.name.downcase.include?(identifier.downcase) }
  end
end

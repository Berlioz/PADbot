class AproposPlugin < PazudoraPluginBase
  def self.aliases
    ["disambiguate", "which"]
  end

  def self.helpstring
"!pad which [NAME]: Returns a set of all monster names which contain NAME as a substring."
  end

  def initialize
    @names = Monster.all.map{|m| [m.name, m.id]}
    p @names
  end

  def respond(m, args)
    p "debug: enterming apropos with #{args}"
    matches = substring_search(args)
    if matches.length > 8
      m.reply("More than 10 results were found; please narrow your query.")
    elsif matches.length == 0
      m.reply("No matches found for substring '#{args}'")
    else
      m.reply "Matches found: " + matches.map{|monster| format(monster)}.join(", ")
    end
  end

  def format(monster)
    "##{monster.id} #{monster.name}" + (monster.stars ? " (#{monster.stars}*)" : "")
  end

  def substring_search(identifier)
    names = @names.select{|m| m.first.downcase.include?(identifier.downcase) }
    names.map{|name, id| Monster.get(id)}
  end
end

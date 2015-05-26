class AproposPlugin < PazudoraPluginBase
  COLOR_WORDS = {"fire" => "fire", "red" => "fire",
                 "water" => "water", "blue" => "water",
                 "wood" => "wood", "green" => "wood",
                 "light" => "light", "white" => "light",
                 "dark" => "dark", "black" => "dark"}

  def self.aliases
    ["apropos", "which"]
  end

  def self.helpstring
"!pad which [NAME]: Returns a set of all monster names which contain NAME as a substring.
!pad which [red|blue|green|light|dark] [NAME]: Filter monsters by PRIMARY color.
Yes, this could be a bit awkward if you're looking for a monster whose name begins with, say, 'red'."
  end

  def initialize
    @names = Monster.all.map{|m| [m.name, m.id]}
    p @names
  end

  def parse_args(args)
    color_test, rest_of_string = args.split(nil, 2)
    if COLOR_WORDS[color_test.downcase]
      return [COLOR_WORDS[color_test.downcase], rest_of_string]
    else
      return [nil, args]
    end
  end

  def respond(m, args)
    color, search_key = parse_args(args)
    matches = substring_search(search_key)
    if color
      matches = matches.select{|m| m.element.split("/").first.downcase == color}
    end

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

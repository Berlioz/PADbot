require 'json'

class ExperiencePlugin < PazudoraPluginBase
  def self.aliases
    ['exp', 'xp', 'experience', 'level', 'levelup']
  end

  def self.helpstring
"!pad exp SEARCHKEY: Tells you how much experience the given monster needs to reach maximum level.
!pad exp SEARCHKEY START: Tells you how much the monster needs to reach maximum level from START."
  end

  def initialize
    @experience_curves = JSON.parse(File.read("data/scraped_xp_curves.json"))
  end

  def respond(m, args)
    argv = args.split(" ")
    if argv.last.to_i != 0
      monstername = argv[0..-2].join(" ")
      starting_level = argv.last.to_i
    else
      monstername = args
      starting_level = 1
    end
    monster = Monster.fuzzy_search(monstername)
    m.reply "Could not match #{monstername} to a monster." && return if monster.nil?
    xp = experience_to_max(monster, starting_level)
    m.reply "#{monster} does not level up." && return if xp.nil?
    while xp < 0
      break if monster.evolved.nil? || monster.evolved.is_a?(Array) # no evolution or ultimate evolution
      monster = Monster.get(monster.evolved)
      xp = experience_to_max(monster, starting_level)
    end
    pengies = (xp / 45000.0).round(2)
    offcolor = (xp / 30000.0).round(2)
    m.reply "To get #{monster} from #{starting_level} to #{monster.max_level} takes #{xp}xp, or #{pengies} (#{offcolor} offcolor) pengdras. Get farming!"
  end

  def experience_to_max(monster, starting_level)
    return nil if monster.curve.nil?
    curve = @experience_curves[monster.curve]
    starting_xp = curve[starting_level.to_s] 
    p monster.max_xp
    p starting_xp 
    monster.max_xp - starting_xp
  end
end

class LookupPlugin < PazudoraPluginBase
  def self.aliases
    ["lookup", "dex", "info"]
  end

  def self.helpstring
    "!pad lookup SEARCHKEY: Returns a description of the given puzzlemon, searching by ID/substring/edit distance.
Examples: !pad lookup horus, !pad lookup 200, !pad lookup the enchanter"
  end

  def generate_monster_entry(m)
    r = "No. #{m.id} #{m.name}, a #{m.stars}* #{m.element} #{m.types.join('/')} monster.\n"
    r += "Deploy Cost: #{m.cost}. Max level: #{m.max_level}, #{m.max_xp} XP to max.\n"
    r += "Awakenings: #{m.awakenings.map{|id| Awakening.lookup(id).name}.join(', ')}\n" unless m.awakenings.empty?
    r += "HP #{m.hp_min}-#{m.hp_max}, ATK #{m.atk_min}-#{m.atk_max}, RCV #{m.rcv_min}-#{m.rcv_max}, BST #{m.bst_min}-#{m.bst_max}\n"
    r += "#{m.skill_text}"
    r += "#{m.leader_text}"
    r
  end

  def respond(m, args)
    puzzlemon = Monster.fuzzy_search(args)
    m.reply "Could not find monster #{args}" && return if puzzlemon.nil?
    m.reply generate_monster_entry(puzzlemon)
  end
end

class QueryPlugin < PazudoraPluginBase
  def self.aliases
    ["query"]
  end

  def self.helpstring
    "!pad query SEARCHKEY QUERY: Finds the monster referenced by SEARCHKEY, then displays only the QUERY'd parameter.
Queries: ID, STARS, ELEMENT, TYPES, COST, AWAKENINGS, SKILL, LEADER, HP, ATK, RCV, BST. 
Examples: !pad lookup horus awakenings, !pad lookup 200 ATK"
  end

  def execute_query(m, query)
    key = query.downcase
    lead = "#{m.name} #{key} => "
    if ['id', 'stars', 'element', 'cost', 'max_level', 'max_xp'].include?(key)
      "#{lead} #{m.send(key)}"
    elsif key == 'skill'
      "#{lead} #{m.skill_text}" 
    elsif key == 'leader' || key == 'leaderskill'
      "#{lead} #{m.leader_text}"
    elsif key == 'awakenings' || key == 'awakening'
      awakening_list = m.awakenings.empty? ? m.awakenings.map{|id| Awakening.lookup(id).name}.join(', ') : "None"
      "#{lead} #{awakening_list}" 
    elsif ['hp', 'atk', 'rv', 'bst'].include?(key)
      "#{lead} #{m.send(key + '_min')} - #{m.send(key + '_max')}" 
    else
      "Malforned query; keyword #{key} not recognized."
    end 
  else

  def respond(m, args)
    search_key = args.split(" ")[0..-2].join(" ")
    query = args.split(" ").last
    puzzlemon = Monster.fuzzy_search(search_key)
    m.reply "Could not find monster #{search_key}" && return if puzzlemon.nil?
    m.reply execute_query(puzzlemon, query)
  end
end



class LookupPlugin < PazudoraPluginBase
  def self.aliases
    ["lookup", "dex", "info"]
  end

  def self.helpstring
    "!pad lookup SEARCHKEY: Returns a description of the given puzzlemon, searching by ID/substring/edit distance.
Examples: !pad lookup horus, !pad lookup 200, !pad lookup the enchanter"
  end

  def generate_monster_entry(m)
    r = "No. #{m.id} #{m.name}, a #{m.stars}* #{m.element} #{m.type} monster.\n"
    r += "Deploy Cost: #{m.cost}. Max level: #{m.max_level}, #{m.max_xp} XP to max.\n"
    r += "Awakenings: #{m.awakenings.join(', ')}\n" unless m.awakenings.empty?
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

require 'open-uri'
require 'openssl'
require 'json'

class PdxPlugin < PazudoraPluginBase
  def self.aliases
    ["pdx"]
  end

  def self.helpstring
    "!pad pdx SEARCHKEY: tries to match SEARCHKEY to a monster, and then post its puzzledragonx page"
  end

  def generate_monster_entry(m)
    r = "#{rem_status(m)} ##{m.id} #{m.name}, a #{m.stars}* #{m.element} #{m.types.join('/')} monster.\n"
    r += "Deploy Cost: #{m.cost}. Max level: #{m.max_level}, #{m.max_xp} XP to max.\n"
    r += "Awakenings: #{m.awakenings.map{|id| Awakening.lookup(id).name}.join(', ')}\n" unless m.awakenings.empty?
    r += "HP #{m.hp_min}-#{m.hp_max}, ATK #{m.atk_min}-#{m.atk_max}, RCV #{m.rcv_min}-#{m.rcv_max}, BST #{m.bst_min
}-#{m.bst_max}\n"
    r += "#{m.skill_text}\n"
    r += "#{m.leader_text}"
    r
  end

  def respond(m, args)
    puzzlemon = Monster.fuzzy_search(args)
    m.reply "Could not find monster #{args}" && return if puzzlemon.nil?
    m.reply "#{puzzlemon.name}: http://puzzledragonx.com/en/monster.asp?n=#{puzzlemon.id}"
  end
end

require 'open-uri'
require 'openssl'
require 'json'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE  

class MonsterPointPlugin < PazudoraPluginBase
  def self.aliases
    ["mp", "shamedragon"]
  end

  def self.helpstring
"!pad mp USER: reads the user's padherder account and totals up its value in MP."
  end

  MP_SHOP = {
    2252 => 300000,
    2253 => 300000,
    2254 => 300000,
    2255 => 300000,
    2256 => 300000,
    2257 => 300000,
    2593 => 300000,
    2594 => 300000,
    2258 => 300000,
    2259 => 300000,
    2260 => 300000,
    2261 => 300000,
    2293 => 250000,
    2294 => 250000,
    2295 => 250000,
    2296 => 250000,
    2297 => 250000,
    2298 => 250000
  }

  def get_box(nick)
    padherder_name = User.fuzzy_lookup(nick).padherder_name rescue nil
    if padherder_name
      j = JSON.parse(open("https://www.padherder.com/user-api/user/#{padherder_name}").read)
      j["monsters"].map{|hash| hash["monster"]}
    else
      nil
    end
  end

  def respond(m, args)
    box = get_box(m.user)
    shamedragon_value = 0
    monster_points = 0

    box.each do |id|
      if MP_SHOP[id]
        shamedragon_value += MP_SHOP[id]
      else
        value = Monster.get(id).monster_points
        monster_points += value if value
      end
    end

    rv = "#{nick}'s box is worth #{monster_points} MP (that's #{(monster_points/300000.0).to_f} shamedragons!)."
    rv += " That's in addition to the #{shamedragon_value} MP in shamedragons they already own..." if shamedragon_value > 0
    m.reply(rv)
  end
end

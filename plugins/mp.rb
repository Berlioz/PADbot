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
    2298 => 250000,
    2755 => 300000,
    2756 => 300000,
    2757 => 300000,
    2758 => 300000,
    2759 => 300000,
    2760 => 300000,
    2761 => 300000,
    2762 => 300000
  }

  def get_box(nick)
    padherder_name = User.fuzzy_lookup(nick).padherder_name rescue nick
    padherder_name = nick unless padherder_name
    j = JSON.parse(open("https://www.padherder.com/user-api/user/#{padherder_name}").read)
    return nil if j["detail"] == "Not found"
    j["monsters"].map{|hash| hash["monster"]}
  end

  def respond(m, args)
    if args && args.length > 0
      username = args
    else
      username = m.user
    end

    box = get_box(username)
    unless box
      m.reply "Cannot find a padherder account which matches #{username}"
      return
    end
    shamedragon_value = 0
    monster_points = 0

    box.each do |id|
      if MP_SHOP[id]
        shamedragon_value += MP_SHOP[id]
      else
        if Monster.get(id).nil?
          print "Bad monster ID #{id} queried by mp plugin\n"
          next
        end
        value = Monster.get(id).monster_points
        monster_points += value if value
      end
    end

    rv = "#{username}'s box is worth #{monster_points} MP (that's #{(monster_points/300000.0).round(2)} shamedragons!)."
    rv += " Plus, the #{shamedragon_value/1000}k MP in shop cards they already own..." if shamedragon_value > 0
    m.reply(rv)
  end
end

require 'open-uri'
require 'openssl'
require 'json'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE  

class TeamsPlugin < PazudoraPluginBase
  def self.aliases
    ["team", "teams"]
  end

  def self.helpstring
    "!pad team <padherder_name>: displays all team names in user's padherder account
!pad team <padherder_name> <team_name>: displays information about a specific team"
  end

  def teams_data(padherder_name)
    j = JSON.parse(open("https://www.padherder.com/user-api/user/#{padherder_name}").read)
    monsters = j["monsters"]
    teams = j["teams"]
    rv = {}
    teams.each do |team|
      rv[team["name"]] = {
        :leader => monsters.detect{|m| m["id"] == team["leader"]},
        :sub1 => monsters.detect{|m| m["id"] == team["sub1"]},
        :sub2 => monsters.detect{|m| m["id"] == team["sub1"]},
        :sub3 => monsters.detect{|m| m["id"] == team["sub1"]},
        :sub4 => monsters.detect{|m| m["id"] == team["sub1"]},
        :friend_leader => Monster.get(team["friend_leader"])
      }
    end
  end

  def pretty_print(team)
    rv = []
    rv << pretty_print_monster(team[:leader])
    rv << pretty_print_monster(team[:sub1])
    rv << pretty_print_monster(team[:sub2])
    rv << pretty_print_monster(team[:sub3])
    rv << pretty_print_monster(team[:sub4])
    rv << "friend #{team[:friend_leader].name}"
    rv.join " / "
  end

  def pretty_print_monster(m_json)
    name = Monster.get(m_json["monster"]).name
    plus = m_json["plus_hp"] + m_json["plus_atk"] + m_json["plus_rcv"]
    skill = m_json["current_skill"]
    "#{name} +#{plus} slvl #{skill}"
  end

  def respond(m, args)
    if args.nil?
      m.reply ("No user or team name arguments given")
      return
    end

    # 1) search registered padherders
    # 2) interpret as user fuzzy search
    # 3) YOLO
    identifier, team_name = args.split(nil, 2)
    user = User.find_by_padherder_name(identifier)
    user = User.fuzzy_search(identifier) if user.nil?
    padherder_name = user ? user.padherder_name : nil
    padherder_name = identifier if padherder_name.nil?

    data = teams_data(padherder_name)
    if team_name
      team_name = team_name.strip.downcase
      team_key = data.keys.detect{|key| key.strip.downcase == team_name}
      team = data[team_key]
      m.reply("#{team_key}: " + pretty_print(team)) if team
    else
      m.reply("#{padherder_name} teams: #{data.keys.join(', ')}")
    end
  end
end
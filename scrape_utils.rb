# from pry, scrape_monster(id) to add it to the database

require 'open-uri'
require 'nokogiri'
require 'pry'
require 'json'
require 'data_mapper'
require 'yaml'
require 'colorize'
require 'openssl'
# I AM A TERRIBLE PERSON THANKS STACKOVERFLOW
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

Dir.glob("models/*.rb").each {|x| require_relative x}

class PadherderAPI
  ONE_OF_EACH_LIT = [[155, 1], [156, 1], [157, 1], [158, 1], [159, 1]]

  def pull_json(endpoint = '')
    JSON.parse(open("https://www.padherder.com/api/#{endpoint}/").read)
  end

  def calculate_predecessors
    predecessors = {}
    @evolutions.each do |id, branches|
      branches.each do |branch|
        if branch["materials"] == ONE_OF_EACH_LIT
          #no-op
        elsif branch["materials"].include?(ONE_OF_EACH_LIT)
          #THANKS VALKYRIES
        else
          predecessors[branch["evolves_to"]] = id.to_i
        end
      end 
    end
    predecessors
  end

  def initialize
    @awakening_ids = {
       "Enhanced HP"=>3,
       "Enhanced Attack"=>4,
       "Enhanced Heal"=>5,
       "Reduce Fire Damage"=>6,
       "Reduce Water Damage"=>7,
       "Reduce Wood Damage"=>8,
       "Reduce Light Damage"=>9,
       "Reduce Dark Damage"=>10,
       "Auto-Recover"=>11,
       "Resistance-Bind"=>12,
       "Resistance-Dark"=>13,
       "Resistance-Jammers"=>14,
       "Resistance-Poison"=>15,
       "Enhanced Fire Orbs"=>16,
       "Enhanced Water Orbs"=>17,
       "Enhanced Wood Orbs"=>18,
       "Enhanced Light Orbs"=>19,
       "Enhanced Dark Orbs"=>20,
       "Extend Time"=>21,
       "Recover Bind"=>22,
       "Skill Boost"=>23,
       "Enhanced Fire Att."=>24,
       "Enhanced Water Att."=>25,
       "Enhanced Wood Att."=>26,
       "Enhanced Light Att."=>27,
       "Enhanced Dark Att."=>28,
       "Two-Pronged Attack"=>29,
       "Resistance-Skill Lock"=>30
    }
    @types = {
      0 => 'Evo Material', 
      1 => 'Balanced',
      2 => 'Physical',
      3 => 'Healer',
      4 => 'Dragon', 
      5 => 'God', 
      6 => 'Attacker', 
      7 => 'Devil', 
      12 => 'Awoken Skill Material', 
      13 => 'Protected', 
      14 => 'Enhance Material'
    }
    @elements = {
      0 => "Fire",
      1 => "Water",
      2 => "Wood",
      3 => "Light",
      4 => "Dark"
    }
    @active_skills = pull_json('active_skills')
    @leader_skills = pull_json('leader_skills')
    @awakenings = pull_json('awakenings')
    @evolutions = pull_json('evolutions')
    @predecessors = calculate_predecessors
    @monsters = pull_json('monsters')
    @experience_curves = JSON.parse(File.read("data/scraped_xp_curves.json"))
  end

  #(Active) Attack Stance - Light: Change Heart orbs to Light orbs. (5-11 turns)
  def format_active_skill(active_skill_name)
    return nil if active_skill_name.nil?
    skill_json = @active_skills.detect{|json| json["name"] == active_skill_name}
    "(Active) #{active_skill_name}: #{skill_json['effect']} (#{skill_json['min_cooldown']}-#{skill_json['max_cooldown']} turns)"
  end

  #(Leader) Pride of the Valkyrie: Healer type cards ATK x2.
  def format_leader_skill(leader_skill_name)
    return nil if leader_skill_name.nil?
    skill_json = @leader_skills.detect{|json| json["name"] == leader_skill_name}
    "(Leader) #{leader_skill_name}: #{skill_json['effect']}"
  end

  def awakenings_to_pdx_ids(json_slug)
    awakenings = json_slug["awoken_skills"]
    awakenings.map { |padherder_id|
      awakening = @awakenings.detect{|a| a["id"] == padherder_id}
      awakening_name = awakening["name"]
      @awakening_ids[awakening_name]
    }
  end
  
  #Fire/Water
  def get_elements(json_slug)
    element1 = @elements[json_slug["element"]]
    if json_slug["element2"]
      element1 + "/#{@elements[json_slug['element2']]}"
    else
      element1
    end
  end

  # ["God", "Devil"]
  def get_types(json_slug)
    type1 = @types[json_slug["type"]]
    if json_slug["type2"]
      [type1 , "#{@types[json_slug['type2']]}"]
    else
      [type1]
    end
  end

  def find_evolutions(internal_id)
    data = @evolutions[internal_id.to_s]
    return nil if data.nil?
    out = data.map{|branch| branch["evolves_to"]}
    out.length == 1 ? out.first : out
  end

  def generate_mats_array(internal_id)
    data = @evolutions[internal_id.to_s]
    return nil if data.nil?
    out = data.map{|branch| 
      rv = []
      branch["materials"].each do |mat|
        mat.last.times do
          rv << mat.first
        end
      end
      rv
    }
    out.length == 1 ? out.first : out
  end

  def max_xp(xp_curve, max_level)
    curve = @experience_curves[xp_curve]
    curve[max_level.to_s] 
  end
  
  def monster_data(json_slug)
    internal_id = json_slug["id"]

    name = json_slug["name"]
    jpname = json_slug["name_jp"]
    max_level = json_slug["max_level"]
    skill_text = format_active_skill(json_slug["active_skill"])
    leader_text = format_leader_skill(json_slug["leader_skill"])
    awakenings = awakenings_to_pdx_ids(json_slug)
    stars = json_slug["rarity"]
    element = get_elements(json_slug)
    cost = json_slug["team_cost"]
    types = get_types(json_slug)
    hp_min = json_slug["hp_min"]
    hp_max = json_slug["hp_max"]
    rcv_min = json_slug["rcv_min"]
    rcv_max = json_slug["rcv_max"]
    atk_min = json_slug["atk_min"]
    atk_max = json_slug["atk_max"]
    bst_min = hp_min + atk_min + rcv_min
    bst_max = hp_max + atk_max + rcv_max
    curve = json_slug["xp_curve"].to_s
    max_xp = max_xp(curve, max_level)

    evolved = find_evolutions(internal_id)
    unevolved = @predecessors[internal_id]
    materials = generate_mats_array(internal_id)

    if materials == [155, 156, 157, 158, 159] # one of each lit
      evolved = nil
      materials = nil
    end

    if materials && materials.include?([155, 156, 157, 158, 159])
      i = materials.index([155, 156, 157, 158, 159])
      evolved.delete_at(i)
      materials.delete_at(i)
    end

    db_id = json_slug["pdx_id"] ? json_slug["pdx_id"] : internal_id

    {
      :id => db_id,
      :name => name,
      :max_level => max_level,
      :max_xp => max_xp,
      :skill_text => skill_text,
      :leader_text => leader_text,
      :awakenings => awakenings,
      :stars => stars,
      :element => element,
      :cost => cost,
      :types => types,
      :hp_min => hp_min,
      :hp_max => hp_max,
      :atk_min => atk_min,
      :atk_max => atk_max,
      :rcv_min => rcv_min,
      :rcv_max => rcv_max,
      :bst_min => bst_min,
      :bst_max => bst_max,
      :evolved => evolved,
      :unevolved => unevolved,
      :materials => materials,
      :curve => curve
    }
  end

  def parse_id(id)
    m = @monsters.detect{|json| json["id"] == id.to_i || json["pdx_id"] == id.to_i}
    m["xp_curve"] = 5000000 if m["xp_curve"] == 6000000
    m["xp_curve"] = 5000000 if m["xp_curve"] == 9900000
    monster_data(m)
  end

  def update_monster(id)
    m = parse_id(id)
    if Monster.get(m[:id])
      p "Updating ##{m[:id]} #{m[:name]}"
      Monster.get(m[:id]).update!(m)
    else
      p "Creating ##{m[:id]} #{m[:name]}"
      Monster.create!(m)   
    end 
  end

  def full_parse(start = 0)
    @monsters.each do |json_slug|
      begin
        json_slug["xp_curve"] = 5000000 if json_slug["xp_curve"] == 6000000
        json_slug["xp_curve"] = 5000000 if json_slug["xp_curve"] == 9999999
        m = monster_data(json_slug)
      rescue Exception => e
        binding.pry
        next
      end
      next if m[:id] < start
      if Monster.get(m[:id])
        #p "Updating ##{m[:id]} #{m[:name]}"
        Monster.get(m[:id]).update!(m) rescue binding.pry
      else
        p "Creating ##{m[:id]} #{m[:name]}"
        Monster.create!(monster_data(json_slug)) rescue binding.pry
      end
    end
  end

  def destructive_parse
    p "Dropping #{Monster.count} entries; hope you know what you're doing..."
    Monster.delete_all
    @monsters.each do |json_slug|
      m = monster_data(json_slug)
      p "Creating ##{m[:id]} #{m[:name]}"
      Monster.create!(monster_data(json_slug))
    end
  end
end


def update_book(start = 0)
  Monster.all.each do |m|
    next unless m.id > start
    p "updating ##{m.id} #{m.name}...".colorize(:green)
    begin
      pp scrape_monster(m.id, :update)
    rescue Exception => e
      p "ERROR updating! #{e.message}".colorize(:red)
    end
  end
end

config = YAML.load(File.read("database_config.yaml"))
DataMapper.setup(:default, config)
DataMapper.finalize

p = PadherderAPI.new

binding.pry

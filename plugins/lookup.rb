require 'open-uri'
require 'openssl'
require 'json'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE  

class LookupPlugin < PazudoraPluginBase
  def self.aliases
    ["lookup", "dex", "info"]
  end

  def self.helpstring
    "!pad lookup SEARCHKEY: Returns a description of the given puzzlemon, searching by ID/substring/edit distance.
Examples: !pad lookup horus, !pad lookup 200, !pad lookup the enchanter"
  end

  def rem_status(m)
    if m.pantheon
      "[#{m.pantheon}]"
    elsif m.rem?
      "[$]"
    else
      "[-]"
    end
  end

  def generate_monster_entry(m)
    r = "#{rem_status(m)} ##{m.id} #{m.name}, a #{m.stars}* #{m.element} #{m.types.join('/')} monster.\n"
    r += "Deploy Cost: #{m.cost}. Max level: #{m.max_level}, #{m.max_xp} XP to max.\n"
    r += "Awakenings: #{m.awakenings.map{|id| Awakening.lookup(id).name}.join(', ')}\n" unless m.awakenings.empty?
    r += "HP #{m.hp_min}-#{m.hp_max}, ATK #{m.atk_min}-#{m.atk_max}, RCV #{m.rcv_min}-#{m.rcv_max}, BST #{m.bst_min}-#{m.bst_max}\n"
    r += "#{m.skill_text}\n"
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
Queries: NAME, ID, STARS, ELEMENT, TYPES, COST, AWAKENINGS, SKILL, LEADER, STATS, HP, ATK, RCV, BST. 
Examples: !pad lookup horus awakenings, !pad lookup 200 ATK"
  end

  # generic: active, leader, atk, hp, rcv, stars, cost
  # types, element, awakenings are inclusion queries
  # special: rem, evolved
  def fake_sql(message, args)
    terms = args.split[1..-1]
    argv = []
    terms.each do |term|
      m = /(\w+)(=|==|>|>=|<|<=|!=|\.like\.|\.include\.)(\w+)/.match(term)
      next unless m
      argv << {:key => m[1].downcase, :operator => m[2].downcase, :value => m[3].downcase}
    end

    p argv
    m = Monster.all
    #handle with sql
    argv.each do |arg|
      key = arg[:key]
      if ['stars', 'cost'].include?(key)
        op = {'=' => 'to_sym', '==' => 'to_sym', '>' => 'gt', '<' => 'lt', '>=' => 'gte', '<=' => 'lte', '!=' => 'not'}[arg[:operator]]
        m = m.all({key.to_sym.send(op) => arg[:value]})
      elsif ['atk', 'hp', 'rcv'].include?(key)
        op = {'=' => 'to_sym', '==' => 'to_sym', '>' => 'gt', '<' => 'lt', '>=' => 'gte', '<=' => 'lte', '!=' => 'not'}[arg[:operator]]
        m = m.all({"#{key}_max".to_sym.send(op) => arg[:value]})
      elsif key == 'leader'
        if arg[:operator] == ".like."
          m = m.all(:leader_text.like => arg[:value])
        elsif arg[:operator] == ".include"
          m = m.all(:leader_text.like => "%#{arg[:value]}%")
        elsif arg[:operator] == "=" || arg[:operator] == "=="
          m = m.all(:leader_text => arg[:value])
        end
      elsif key == 'active'
        if arg[:operator] == ".like."
          m = m.all(:skill_text.like => arg[:value])
        elsif arg[:operator] == ".include"
          m = m.all(:skill_text.like => "%#{arg[:value]}%")
        elsif arg[:operator] == "=" || arg[:operator] == "=="
          m = m.all(:skill_text => arg[:value])
        end   
      end
    end
    # handle in ruby, convert relation to array
    argv.each do |arg|
      key = arg[:key]
      if key == 'type' || key == 'types'
        if ['=', '==', '.include.'].include? arg[:operator]
          m = m.select{|monster| monster.types.map(&:downcase).include?(arg[:value].downcase)}
        end    
      elsif key == 'awakenings' || key == 'awakening'
        awakening = Awakening.find_by_name(arg[:value].tr('-_:', ' '))
        next if awakening.nil?
        if ['=', '==', '.include.'].include? arg[:operator]
          m = m.select{|monster| monster.awakenings.include?(awakening.id)}
        end
      elsif key == 'element' || key == 'elements'
        if ['=', '==', '.include.'].include? arg[:operator]
          m = m.select{|monster| monster.element.split("/").map(&:downcase).include?(arg[:value].downcase)}
        end   
      end
    end

    terms.each do |term|
      if term.downcase == "evolved"
        m = m.select{|monster| monster.evolved.nil?}
      elsif term.downcase == "padherder" || term.downcase == "herder"
        user_owned = get_box(message.user.nick)
        if user_owned.nil?
          message.reply "Failed to establish padherder API link for #{message.user.nick}." and return
        end
        m = m.select{|monster| user_owned.include?(monster.id)}
      end
    end

    results = m
 
    if message.channel && results.count >= 15
      message.reply "Query matched #{results.count} records; please refine or PM me out of channel."
    else
      lead = "Query"
      message.reply "#{lead}: #{results.map{|r| list_monster(r)}.join('; ')}"
    end
  end

  def get_box(nick)
    padherder_name = User.fuzzy_lookup(nick).padherder_name rescue nil
    if padherder_name
      j = JSON.parse(open("https://www.padherder.com/user-api/user/#{padherder_name}").read)
      box = j["monsters"].map{|hash| hash["monster"]}.uniq
      box
    else
      nil
    end
  end

  def list_monster(monster)
    "##{monster.id} #{monster.name}"
  end

  def execute_query(m, query)
    key = query.downcase
    lead = "#{m.name} #{key} =>"
    if ['name', 'id', 'stars', 'element', 'cost', 'max_level', 'max_xp'].include?(key)
      "#{lead} #{m.send(key)}"
    elsif key == 'type' || key == 'types'
      "#{lead} #{m.types.join(',')}"
    elsif key == "element" || key == "elements"
      "#{lead} #{m.element}"
    elsif key == 'skill' || key == 'active'
      "#{lead} #{m.skill_text}" 
    elsif key == 'leader' || key == 'leaderskill'
      "#{lead} #{m.leader_text}"
    elsif key == 'awakenings' || key == 'awakening'
      while (m.awakenings.empty? && m.evolved)
        m = Monster.get( m.evolved.is_a?(Array) ? m.evolved.first : m.evolved )
      end
      awakening_list = m.awakenings.map{|id| Awakening.lookup(id).name}.join(', ')
      "#{lead} #{awakening_list}" 
    elsif key == 'stats'
      "#{lead} HP #{m.hp_min} - #{m.hp_max}, ATK #{m.atk_min} - #{m.atk_max}, RCV #{m.rcv_min} - #{m.rcv_max}, BST #{m.bst_min} - #{m.bst_max}"
    elsif ['hp', 'atk', 'rv', 'bst'].include?(key)
      "#{lead} #{m.send(key + '_min')} - #{m.send(key + '_max')}" 
    else
      "No query key found; use !lookup to display all information about a monster."
    end 
  end

  def respond(m, args)
    if args.split.first.downcase == "where"
      fake_sql(m, args)
      return
    end

    search_key = args.split(" ")[0..-2].join(" ")
    query = args.split(" ").last
    puzzlemon = Monster.fuzzy_search(search_key)
    m.reply "Could not find monster #{search_key}" && return if puzzlemon.nil?
    m.reply execute_query(puzzlemon, query)
  end
end



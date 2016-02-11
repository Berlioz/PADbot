require 'levenshtein'

class Monster
  include DataMapper::Resource

  property :id, Integer, :key => true
  property :name, String
  property :max_level, Integer
  property :max_xp, Integer
  property :monster_points, Integer
  property :skill_text, Text
  property :leader_text, Text
  property :awakenings, Object
  property :stars, Integer
  property :element, String
  property :cost, Integer
  property :types, Object
  property :hp_min, Integer
  property :atk_min, Integer
  property :rcv_min, Integer
  property :bst_min, Integer
  property :hp_max, Integer
  property :atk_max, Integer
  property :rcv_max, Integer
  property :bst_max, Integer
  property :curve, String

  #integer arrays, since monsters can have multiple materials andultimate evos
  property :unevolved, Object
  property :evolved, Object
  property :materials, Object

  property :rem, Boolean
  property :pantheon, String

  NAME_SPECIAL_CASES = {
    "blodin" => "odin, the war deity",
    "grodin" => "odin",
    "rodin" => "1107",
    "blue odin" => "odin, the war deity",
    "green odin" => "odin",
    "red odin" => "1107",
    "green sonia" => "913",
    "red sonia" => "911",
    "blue sonia" => "1088",
    "gronia" => "913",
    "ronia" => "911",
    "blonia" => "1088",
    "light metatron" => "archangel metatron",
    "l metatron" => "archangel metatron",
    "dark metatron" => "dark angel metatron",
    "d metatron" => "dark angel metatron",
    "cuchu" => "cu chulainn",
    "chuchoo" => "cu chulainn",
    "catte" => "love deity feline of harmony, bastet",
    "u&y" => "umisachi&yamasachi",
    "batman" => "9320",
    "d/d batman" => "9320",
    "dd batman" => "9320",
    "d/d bats" => "9320",
    "dl batman" => "9300",
    "d/l batman" => "9300",
    "d/l bats" => "9300",
    "dw batman" => "9340",
    "d/w batman" => "9340",
    "d/w bats" => "9340",
    "joker" => "9240",
    "fa lucifer" => "638",
    "retard lucifer" => "638",
    "best lucifer" => "638",
    "sod lucifer" => "629",
    "aa lucifer" => "628",
    "shirtless vampire" => "dark liege, vampire duke",
    "shirted vampire" => "arcane monarch, vampire duke",
    "minisuzaku" => "1786",
    "minironia" => "1793",
    "miniseiryuu" => "1787",
    "minigenbu" => "1788",
    "minivalk" => "1785",
    "minivalkyrie" => "1785",
    "minikirin" => "1789",
    "minilmeta" => "1792",
    "minimetatron" => "1792",
    "minililith" => "1784",
    "minibyakko" => "1790",
    "miniyomi" => "1791",
    "minilucifer" => "1794",
    "miniluci" => "1794",
    "dark valk" => "982",
    "dark valkyrie" => "982",
    "blue valk" => "972",
    "blue valkyrie" => "972",
    "water valk" => "972",
    "water valkyrie" => "972",
    "green valk" => "1516",
    "green valkyrie" => "1516",
    "wood valk" => "1516",
    "wood valkyrie" => "1516",
    "red valk" => "1270",
    "red valkyrie" => "1270",
    "fire valk" => "1270",
    "fire valkyrie" => "1270",
    "lkali" => "1585",
    "light kali" => "1585",
    "dkali" => "1587",
    "dark kali" => "1587"
  }

  def self.fuzzy_match(identifier)
    self.fuzzy_search(identifier)
  end

  def self.fuzzy_search(identifier)
    prefix, identifier_t = prefix_split(identifier)
    new_identifier = NAME_SPECIAL_CASES[identifier_t.downcase]
    identifier_t = new_identifier if new_identifier
    if identifier_t =~ /\A\d+\z/
      id = identifier_t.to_i
      match = self.first(:id => id)
    else
      match = substring_search(identifier_t)
      if match.nil?
        match = edit_distance_search(identifier_t)
      end
    end

    if match && prefix
      match = apply_prefix(prefix, match)
    end
    return match
  end

  def self.prefix_split(identifier)
    test = identifier.split(' ', 2).first
    remainder = identifier.split(' ', 2).last
    if test =~ /\A\d\*\z/ || test.downcase.include?("evolved") || test.downcase == "base"
      return test,remainder
    else
      return nil, identifier
    end
  end

  def self.apply_prefix(prefix, monster)
    current_monster = monster
    if prefix =~ /\A\d\*\z/
      target = prefix.to_i
      while current_monster.stars != target
        if current_monster.stars < target
          current_monster = current_monster.get_evolved
        else
          current_monster = current_monster.get_unevolved 
        end
        return monster if current_monster.nil?
      end
      return current_monster
    elsif prefix.downcase == "evolved"
      while current_monster.get_evolved
        current_monster = current_monster.get_evolved
      end
      return current_monster  
    elsif prefix.downcase.include? "evolved"
      type_bias = prefix.split('_', 2).first
      while current_monster.get_evolved(type_bias)
        current_monster = current_monster.get_evolved(type_bias)
      end
      return current_monster  
    elsif prefix.downcase == "base"
      while current_monster.get_unevolved
        current_monster = current_monster.get_unevolved
      end
      return current_monster 
    else
      monster
    end
  end

  def self.substring_search(identifier)
    names = self.all.map(&:name)
    matches = names.select{|x| x.downcase.include?(identifier.downcase) }
    return nil if matches.empty?
    choice = matches[matches.map{|current| Levenshtein.distance(identifier.downcase, current.downcase)}.each_with_index.min.last]
    self.first(:name => choice) 
  end

  def self.edit_distance_search(identifier)
    limit = (identifier.length) / 3
    limit = 3 if limit < 3
    names = self.all.map(&:name)
    choice = names[names.map{|current| Levenshtein.distance(identifier.downcase, current.downcase)}.each_with_index.min.last]
    return nil if Levenshtein.distance(identifier.downcase, choice.downcase) > limit
    self.first(:name => choice)
  end

  def get_evolved(type_string = nil)
    if evolved.is_a? Array || evolved.length > 1
      case type_string
      when 'dark', 'd', 'black'
        m_id = evolved.detect{|id| Monster.get(id).element.include?('/Dark')}
      when 'light', 'l', 'white'
        m_id = evolved.detect{|id| Monster.get(id).element.include?('/Light')}
      when 'wood', 'g', 'green'
        m_id = evolved.detect{|id| Monster.get(id).element.include?('/Wood')}
      when 'water', 'w', 'blue'
        m_id = evolved.detect{|id| Monster.get(id).element.include?('/Water')}
      when 'fire', 'f', 'red'
        m_id = evolved.detect{|id| Monster.get(id).element.include?('/Fire')}
      else
        m_id = evolved.first
      end
      Monster.get(m_id)
    elsif evolved.is_a? Array
      Monster.get(evolved.first)
    else
      evolved == nil ? nil : Monster.get(evolved)
    end
  end

  def get_unevolved
    unevolved == nil ? nil : Monster.get(unevolved)
  end

  def to_s
    name 
  end
end

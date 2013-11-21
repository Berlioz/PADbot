require 'levenshtein'

class Monster
  include DataMapper::Resource

  property :id, Integer, :key => true
  property :name, String
  property :max_level, Integer
  property :max_xp, Integer
  property :skill_text, Text
  property :leader_text, Text
  property :awakenings, Object
  property :stars, Integer
  property :element, String
  property :cost, Integer
  property :type, String
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
    "light metatron" => "archangel metatron",
    "l metatron" => "archangel metatron",
    "dark metatron" => "dark angel metatron",
    "d metatron" => "dark angel metatron",
    "cuchu" => "cu chulainn",
    "chuchoo" => "cu chulainn",
    "catte" => "love deity feline of harmony, bastet"
  }

  def self.fuzzy_search(identifier)
    if identifier =~ /\A\d+\z/
      id = identifier.to_i
      self.first(:id => id)
    else
      prefix, identifier_t = prefix_split(identifier)

      new_identifier = NAME_SPECIAL_CASES[identifier_t.downcase]
      identifier_t = new_identifier if new_identifier

      match = substring_search(identifier_t)
      if match.nil?
        match = edit_distance_search(identifier_t)
      end
      if match && prefix
        match = apply_prefix(prefix, match)
      end
      match
    end
  end

  def self.prefix_split(identifier)
    test = identifier.split(' ', 2).first
    remainder = identifier.split(' ', 2).last
    if test =~ /\A\d\*\z/ || test.downcase == "evolved" || test.downcase == "base"
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

  def get_evolved
    evolved == nil ? nil : Monster.get(evolved)
  end

  def get_unevolved
    unevolved == nil ? nil : Monster.get(unevolved)
  end

  def to_s
    name 
  end
end

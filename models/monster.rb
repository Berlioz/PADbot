require 'levenshtein'

class Monster
  include DataMapper::Resource

  property :id, Integer, :key => true
  property :name, String
  property :max_level, Integer
  property :max_xp, Integer
  property :skill_text, Text
  property :leader_text, Text
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

  def self.fuzzy_search(identifier)
    if identifier.to_i != 0
      id = identifier.to_i
      self.first(:id => id)
    else
      match = substring_search(identifier)
      if match.nil?
        edit_distance_search(identifier)
      else
        match
      end
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
end

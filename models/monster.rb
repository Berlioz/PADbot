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
end

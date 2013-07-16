require 'data_mapper'
require 'json'
require 'yaml'
Dir.glob("models/*.rb").each {|x| require_relative x}

def extract_material_id(line)
  line.gsub(/[^0-9]/,"").to_i
end

def import_monsters
  # Pass 1: populate monster data
  old_database = JSON.parse(File.read("imports/scraped_monsters.json"))
  old_database.each do |id, data|
    associations = ["evo_chain", "evo_mats"]
    simple_data = data.delete_if{|k, _| associations.include?(k)}
    simple_data = simple_data.merge({"id" => id})
    Monster.create(simple_data)
  end
end

def import_monster_associations
  # Pass 2: associations
  old_database = JSON.parse(File.read("imports/scraped_monsters.json"))
  old_database.each do |id, data|
    base_monster = Monster.first(:id => id.to_i)

    materials = data["evo_mats"]
    material_ids = materials.map do |x|
      if x.respond_to? :each
        x.map{|y| extract_material_id(y)}
      else
        extract_material_id(x)
      end
    end
    base_monster.materials = material_ids

    evolution_chain = data["evo_chain"]
    own_index = evolution_chain.index(base_monster.name) 
    unless own_index.nil? || own_index == 0
      predecessor_name = evolution_chain[own_index - 1]
      predecessor = Monster.first(:name => predecessor_name)
      p "WARNING: Could not find association #{predecessor_name} for monster #{id}" if predecessor.nil?
      base_monster.unevolved = predecessor.id unless predecessor.nil?
    end   
    unless own_index.nil? || own_index == (evolution_chain.length - 1)
      successor_name = evolution_chain[own_index + 1]
      if successor_name.include? "busty"
        successors = evolution_chain.slice(own_index + 1, evolution_chain.length + 1)
        successors = successors.map{|line| line.gsub("(busty)", "").strip}   
        successor_ids = successors.map{|name| Monster.first(:name => name)}
        base_monster.evolved = successor_ids   
      else
        successor = Monster.first(:name => successor_name)
        p "WARNING: Could not find association #{predecessor_name} for monster #{id}" if successor.nil?
        base_monster.evolved = successor.id  unless successor.nil?
      end
    end   
    base_monster.save
  end
end

def import_users
  old_database = YAML.load(File.read("imports/pddata.yml"))
  old_database.each do |handle, data|
    known_names = ([handle] + [data[:added_by]]).uniq
    User.create(
      :registered_name => handle,
      :irc_aliases => known_names,
      :pad_code => data[:friend_code].gsub(/[^0-9]/,"").to_i,
      :is_admin => false
    )
  end 
end

config = JSON.parse(File.read("database_config.json"))
DataMapper.setup(:default, config)
DataMapper.finalize
DataMapper.auto_migrate!
import_monsters
import_monster_associations
import_users

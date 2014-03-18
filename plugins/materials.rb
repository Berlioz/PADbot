class MatsPlugin < PazudoraPluginBase
  def self.aliases
    ["mats", "evolution", "evo"]
  end

  def self.helpstring
"!pad mats SEARCHKEY: Lists the evolution materials the given monster needs to evolve to its next stage, if any."
  end

  def respond(m, args)
    puzzlemon = Monster.fuzzy_search(args)
    m.reply "Could not find monster #{args}" && return if puzzlemon.nil?
    msg = "#{puzzlemon} evolution materials: "
    if puzzlemon.materials.first.is_a? Array
      ultimates = puzzlemon.materials.map{|evo| ids_to_names(evo).join(", ")}
      msg += ultimates.join(" | ")
    else
      msg += ids_to_names(puzzlemon.materials).join(", ")
    end
    m.reply msg
  end

  def ids_to_names(ids)
    ids.map do |id|
      Monster.first(:id => id).name
    end
  end
end

class MatsForPlugin < PazudoraPluginBase
  def self.aliases
    ["mats_for", "evolution_to"]
  end

  def self.helpstring
"!pad mats_for SEARCHKEY: Lists the evolution materials the given monster needs to evolve from its previous stage."
  end

  def respond(m, args)
    puzzlemon = Monster.fuzzy_search(args)
    previous = Monster.get(puzzlemon.unevolved) rescue nil
    m.reply "Could not find monster #{args}" && return if puzzlemon.nil?
    m.reply "Monster #{puzzlemon} does not have an unevolved form" && return if previous.nil?
    msg = "#{previous} => #{puzzlemon} materials: "
    if previous.materials.first.is_a? Array
      i = previous.evolved.index(puzzlemon.id)
      msg == ids_to_names(previous.materials[i].join(", "))
    else
      msg += ids_to_names(previous.materials).join(", ")
    end
    m.reply msg
  end

  def ids_to_names(ids)
    ids.map do |id|
      Monster.first(:id => id).name
    end
  end
end

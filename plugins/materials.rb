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

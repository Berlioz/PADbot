class ChainPlugin < PazudoraPluginBase
  def self.aliases
    ["chain"]
  end

  def self.helpstring
"!pad chain SEARCHKEY: Lists all monsters the given monster can evolve to or from."
  end

  def respond(m, args)
    puzzlemon = Monster.fuzzy_search(args)
    m.reply "Could not find monster #{args}" && return if puzzlemon.nil?
    chain = [puzzlemon.name]
    predecessor = puzzlemon
    while predecessor.unevolved
      chain = [Monster.first(:id => predecessor.unevolved).name] + chain
      predecessor = Monster.first(:id => predecessor.unevolved)
    end
    successor = puzzlemon
    while successor.evolved
      if successor.evolved.is_a? Array
        names = successor.evolved.map{|m| Monster.get(m).name}
        chain = chain + names
        break
      else
        chain << Monster.first(:id => successor.evolved).name
        successor = Monster.first(:id => successor.evolved)
      end
    end
    if chain.length == 1
      m.reply "#{puzzlemon} is not part of an evolution chain."
    else
      m.reply chain.join(", ")
    end
  end
end

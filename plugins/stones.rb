class StonesPlugin < PazudoraPluginBase
  def self.aliases
    ["stones", "whale", "ahab"]
  end

  def self.helpstring
    "!pad stones $X: tells you how many stones $X will buy you.
     !pad stones Y: tells you how much Y stones will cost you."
  end

  def stone_price(stones)
    prices = {1 => 1, 6 => 5, 12 => 10, 30 => 23, 60 => 44, 85 => 60}
    money = 0
    while stones > 0
      selection = prices.keys.select{|x| x <= stones}.max
      stones = stones - selection
      money = money + prices[selection]
    end
    money
  end

  def stone_yield(dollars)
    yields = {1 => 1, 5 => 6, 10 => 12, 23 => 30, 44 => 60, 60 => 85}
    stones = 0
    while dollars > 0
      selection = yields.keys.select{|x| x <= dollars}.max
      dollars -= selection
      stones += yields[selection]
    end
    stones
  end

  def respond(m, args)
    args = "" unless args
    if args[0] == "$"
      dollars = args[1..-1].to_i
      m.reply("$#{dollars} = #{stone_yield(dollars)} stones")
    elsif args.to_i != 0
      stones = args.to_i
      m.reply("#{stones} stones = $#{stone_price(stones)}")
    else
      m.reply "???"
    end
  end
end

class SummerRemPlugin < PazudoraPluginBase
  def self.aliases
    ["summer", "beach", "whalesong"]
  end

  def self.helpstring
"!pad summer: Simulates a roll from the Summer REM."
  end

  def reachable?(key)
    [2290, 2287, 2292, 2291, 2289, 1518, 2315, 2314, 1784, 1785, 1791, 1794, 2286, 1786, 1787, 1788, 1789, 1790].each do |id|
      return true if Monster.get(id).name.downcase.include?(key.downcase)
    end
    false
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

  # 8*: 0.3% (lmao)
  # 7*: 2.7%
  # 6*: 7%
  # 5*: 15%
  # 4*: 75%
  def roll_id
  	test = rand(1000)
  	if test <= 3
  	  [2290].sample
  	elsif test <= 30
  	  [2287, 2292].sample
  	elsif test <= 100
  	  [2291, 2289, 1518].sample
    elsif test <= 250
      [2315, 2314, 1784, 1785, 1791, 1794].sample
  	else
  	  [2286, 1786, 1787, 1788, 1789, 1790].sample
  	end
  end

  def pull
  	Monster.get(roll_id)
  end

  def respond(m, args)
    if args.nil?
      roll = pull
      m.reply("You rolled ##{roll.id} #{roll.name} (#{roll.stars}*)")
    elsif args.to_i != 0
      rv = []
      if args.to_i > 500
        m.reply ("dick.") and return
      end
      count = args.to_i
      rolls = []
      count.times do |n|
        rolls << roll_id
      end
      
      [2290, 2287, 2292, 2291, 2289, 1518, 2286].each do |target|
        next unless rolls.include?(target)
        monster = Monster.get(target)
        dupes = rolls.grep(target).count
        if dupes > 1
          rv << "#{dupes}x #{monster.name}"
        else
          rv << "#{monster.name}"
        end
      end

      golds = rolls.select{|id| [2315, 2314, 1784, 1785, 1791, 1794].include?(id)}.count
      if golds > 0
      	rv << "#{golds}x gold eggs"
      end

      silvers = rolls.select{|id| [1786, 1787, 1788, 1789, 1790].include?(id)}.count
      if silvers > 0
      	rv << "#{silvers}x silver eggs"
      end
      price = stone_price(count * 5)

      m.reply("#{count} pulls ($#{price}): #{rv.join(', ')}")
    else
      search_key = args  
      if !reachable?(search_key)
        m.reply("'#{search_key}' doesn't correspond to anything in the Summer REM")
      end
      attempts = 0
      monster = nil
      loop do
      	attempts += 1
        monster = pull
        break if monster.name.downcase.include?(search_key.downcase)
      end
      price = stone_price(attempts * 5)
      m.reply "After #{attempts} attempts and $#{price}, you rolled ##{monster.id} #{monster.name}"
    end
  end
end

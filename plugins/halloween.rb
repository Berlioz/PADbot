# encoding: utf-8

class HalloweenPlugin < PazudoraPluginBase
  def self.aliases
    ["halloween", "candy"]
  end

  def self.helpstring
"!pad halloween: Simulates a roll from the Halloween rem."
  end

  def reachable?(key)
    [1412, 1414, 1416, 1418, 1420, 2408, 2412, 1791, 1785, 1626, 1620, 634, 638, 1783, 2314, 2315, 1794, 1624, 1622, 1616, 1618, 630, 632, 636, 1793, 1792, 2316, 2409, 2410, 2411, 2406, 2407].each do |id|
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

  # 4* : 63%
  # 5* : 27%
  # 6* : 7.2%
  # 7* : 2%
  # 8* : 0.8%
  def roll_id
  	test = rand(1000)
  	if test <= 630
  	  [1412, 1414, 1416, 1418, 1420, 2408, 2412].sample
  	elsif test <= 900
  	  [1791, 1785, 1626, 1620, 634, 638, 1783, 2314, 2315, 1794, 1624, 1622, 1616, 1618, 630, 632, 636 ].sample
        elsif test <= 972
	  [1793, 1792, 2316, 2409, 2410, 2411].sample
        elsif test <= 992
          2406
        else
          2407
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
      
      [2406, 2407, 2409, 2410, 2411, 2408, 2412, 1793, 1792, 2316].each do |target|
        next unless rolls.include?(target)
        monster = Monster.get(target)
        dupes = rolls.grep(target).count
        if dupes > 1
          rv << "#{dupes}x #{monster.name}"
        else
          rv << "#{monster.name}"
        end
      end

      silvers = rolls.select{|id| [1412, 1414, 1416, 1418, 1420].include?(id)}.count
      if silvers > 0
      	rv << "#{silvers}x silver eggs"
      end

      golds = rolls.select{|id| [1791, 1785, 1626, 1620, 634, 638, 1783, 2314, 2315, 1794, 1624, 1622, 1616, 1618, 630, 632, 636 ].include?(id)}.count
      if golds > 0
      	rv << "#{golds}x gold eggs"
      end

      price = stone_price(count * 5)
      m.reply("#{count} pulls ($#{price}): #{rv.join('; ')}")
    else
      search_key = args  
      if !reachable?(search_key)
        m.reply("'#{search_key}' doesn't correspond to anything in the Halloween REM")
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

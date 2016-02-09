class NewYearRemPlugin < PazudoraPluginBase
  def self.aliases
    ["newyear", "newyears", "ny"]
  end

  def self.helpstring
"!pad newyear: Simulates a roll from the New Year rem."
  end

  def reachable?(key)
    [2542, 2541, 2540, 2539, 2574, 2538, 2535, 2537, 2536, 2534, 2533].each do |id|
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

  def roll_id
    test = rand(1000)
    if test <= 800
  	  [2542, 2541, 2540, 2539].sample
    elsif test <= 900
  	  [2574, 2538].sample
    elsif test <= 960
      2535
    elsif test <= 986
  	  [2537, 2536].sample
    else
  	  [2534, 2533].sample
    end
  end

  def pull
  	Monster.get(roll_id)
  end

  def respond(m, args)
    if args.nil?
      roll = pull
      log_spending(5)
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
      
      [2535, 2537, 2536, 2534, 2533].each do |target|
        next unless rolls.include?(target)
        monster = Monster.get(target)
        dupes = rolls.grep(target).count
        if dupes > 1
          rv << "#{dupes}x #{monster.name}"
        else
          rv << "#{monster.name}"
        end
      end

      golds = rolls.select{|id| [2574, 2538].include?(id)}.count
      if golds > 0
      	rv << "#{golds}x gold eggs"
      end

      silvers = rolls.select{|id| [2542, 2541, 2540, 2539].include?(id)}.count
      if silvers > 0
      	rv << "#{silvers}x silver eggs"
      end
      price = stone_price(count * 5)
      log_spending(price)

      m.reply("#{count} pulls ($#{price}): #{rv.join(', ')}")
    else
      search_key = args  
      if !reachable?(search_key)
        m.reply("'#{search_key}' doesn't correspond to anything in the Academy REM")
      end
      attempts = 0
      monster = nil
      loop do
      	attempts += 1
        monster = pull
        break if monster.name.downcase.include?(search_key.downcase)
      end
      price = stone_price(attempts * 5)
      log_spending(price)
      m.reply "After #{attempts} attempts and $#{price}, you rolled ##{monster.id} #{monster.name}"
    end
  end
end


class FinalFantasyRemPlugin < PazudoraPluginBase
  def self.aliases
    ["ff", "belts", "nomura"]
  end

  def self.helpstring
"!pad belts: Simulates a roll from the Final Fantasy rem."
  end

  def reachable?(key)
    [2045, 2783, 2047, 2049, 2039, 2033, 2776, 2772, 2035, 2041, 2782, 2037, 2770, 2774, 2029, 2043, 2778, 2031, 2767].each do |id|
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

  # 4* : 35%
  # 5* : 45%
  # 6* : 20%
  def roll_id
  	test = rand(1000)
  	if test <= 350
  	  [2045, 2783, 2047, 2049, 2039].sample
  	elsif test <= 800
  	  [2033, 2776, 2772, 2035, 2041, 2782, 2037, 2770, 2774].sample
  	else
  	  [2029, 2043, 2778, 2031, 2767].sample
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
      
      [2033, 2776, 2772, 2035, 2041, 2782, 2037, 2770, 2774, 2029, 2043, 2778, 2031, 2767].each do |target|
        next unless rolls.include?(target)
        monster = Monster.get(target)
        dupes = rolls.grep(target).count
        if dupes > 1
          rv << "#{dupes}x #{monster.name}"
        else
          rv << "#{monster.name}"
        end
      end

      silvers = rolls.select{|id| [2045, 2783, 2047, 2049, 2039].include?(id)}.count
      if silvers > 0
      	rv << "#{silvers}x silver eggs"
      end
      price = stone_price(count * 5)
      log_spending(price)

      m.reply("#{count} pulls ($#{price}): #{rv.join(', ')}")
    else
      search_key = args  
      if !reachable?(search_key)
        m.reply("'#{search_key}' doesn't correspond to anything in the FF REM")
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

class BatremPlugin < PazudoraPluginBase
  def self.aliases
    ["batrem", "batman", "batroll"]
  end

  def self.helpstring
"!pad batrem: Simulates a roll from the Batman rem."
  end

  def reachable?(key)
    [671, 673, 675, 677, 679].each do |id|
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

  # 4* : 85%
  # 5* : 10%
  # 6* : 3.5%
  # 7* : 1.5%
  def roll_id
    test = rand(1000)
    if test <= 100
      [675, 679].sample
    else
      [671, 673, 677].sample
    end
  end

  def pull
    Monster.get(roll_id)
  end

  def respond(m, args)
    if args.nil?
      roll = pull
      log_spending(5)
      m.reply("You rolled ##{roll.id} #{roll.name} (#{roll.stars}* #{roll.element})")
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
      
      [671, 673, 675, 677, 679].each do |target|
        next unless rolls.include?(target)
        monster = Monster.get(target)
        dupes = rolls.grep(target).count
        if dupes > 1
          rv << "#{dupes}x #{monster.name}"
        else
          rv << "#{monster.name}"
        end
      end

      price = stone_price(count * 5)
      log_spending(price)

      m.reply("#{count} pulls ($#{price}): #{rv.join(', ')}")
    else
      search_key = args  
      if !reachable?(search_key)
        m.reply("'#{search_key}' doesn't correspond to anything in the batman REM")
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


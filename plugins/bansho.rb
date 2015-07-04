# gold eggs: 1967, 1972, 1970 4% ea.
# silver eggs: 1974, 1975, 1976, 1977, 1978, 1979, 1980, 1981 11% ea.

class ShinraBanshoRemPlugin < PazudoraPluginBase
  def self.aliases
    ["shinra", "bansho"]
  end

  def self.helpstring
"!pad bansho: Simulates a roll from the PAD Academy rem."
  end

  def reachable?(key)
    [1967, 1972, 1970, 1974, 1975, 1976, 1977, 1978, 1979, 1980, 1981].each do |id|
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
  	if test <= 880
  	  [1974, 1975, 1976, 1977, 1978, 1979, 1980, 1981].sample
  	else
  	  [1967, 1972, 1970].sample
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
      
      [1967, 1972, 1970].each do |target|
        next unless rolls.include?(target)
        monster = Monster.get(target)
        dupes = rolls.grep(target).count
        if dupes > 1
          rv << "#{dupes}x #{monster.name}"
        else
          rv << "#{monster.name}"
        end
      end

      silvers = rolls.select{|id| [1974, 1975, 1976, 1977, 1978, 1979, 1980, 1981].include?(id)}.count
      if silvers > 0
      	rv << "#{silvers}x silver eggs"
      end

      price = stone_price(count * 5)
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
      m.reply "After #{attempts} attempts and $#{price}, you rolled ##{monster.id} #{monster.name}"
    end
  end
end

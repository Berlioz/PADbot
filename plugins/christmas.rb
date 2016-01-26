# encoding: utf-8

# 8* 2512 2511 0.6% ea.
# 7* 2% 2514 2510
# 6* 2.5% 1782 2513
# 4* 2515 2517 2516 2518 2519 2520 15% lol

class ChristmasRemPlugin < PazudoraPluginBase
  def self.aliases
    ["xmas", "christmas"]
  end

  def self.helpstring
"!pad xmas: Simulates a roll from the 2015 Christmas rem."
  end

  def reachable?(key)
    [2512, 2511, 2514, 2510, 1782, 2513, 2515, 2517, 2516, 2518, 2519, 2520].each do |id|
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
  	if test <= 900
  	  [2515, 2516, 2517, 2518, 2519, 2520].sample
  	elsif test <= 950
  	  [1782, 2513].sample
        elsif test <= 990
          [2514, 2510].sample
        else
          [2512, 2511].sample
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
      
      [2512, 2511, 2514, 2510, 1782, 2513].each do |target|
        next unless rolls.include?(target)
        monster = Monster.get(target)
        dupes = rolls.grep(target).count
        if dupes > 1
          rv << "#{dupes}x #{monster.name}"
        else
          rv << "#{monster.name}"
        end
      end

      silvers = rolls.select{|id| [2515, 2516, 2517, 2518, 2519, 2520].include?(id)}.count
      if silvers > 0
      	rv << "#{silvers}x silver eggs"
      end

      price = stone_price(count * 5)
      m.reply("#{count} pulls ($#{price}): #{rv.join(', ')}")
    else
      search_key = args  
      if !reachable?(search_key)
        m.reply("'#{search_key}' doesn't correspond to anything in the 2015 Christmas REM")
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

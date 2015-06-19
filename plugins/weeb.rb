class WeeabooRemPlugin < PazudoraPluginBase
  def self.aliases
    ["academy", "weeb", "senpai"]
  end

  def self.helpstring
"!pad academy: Simulates a roll from the PAD Academy rem."
  end

  def reachable?(key)
    [2023, 2024, 2025, 2026, 2027, 2028, 1065, 1067, 1069, 1071, 1073, 1626, 2020, 2021, 2022, 2014, 2015, 2017].each do |id|
      return true if Monster.get(id).name.downcase.include?(key.downcase)
    end
    false
  end

  # 4* : 85%
  # 5* : 10%
  # 6* : 3.5%
  # 7* : 1.5%
  def roll_id
  	test = rand(1000)
  	if test <= 850
  	  [2023, 2024, 2025, 2026, 2027, 2028].sample
  	elsif test <= 950
  	  [1065, 1067, 1069, 1071, 1073, 1626].sample
  	elsif test <= 985
  	  [2020, 2021, 2022].sample
  	else
  	  [2014, 2015, 2017].sample
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
      if args.to_i > 100
        m.reply ("dick.") and return
      end
      count = args.to_i
      rolls = []
      count.times do |n|
        rolls << roll_id
      end
      
      [2014, 2015, 2017, 2020, 2021, 2022].each do |target|
        next unless rolls.include?(target)
        monster = Monster.get(target)
        dupes = rolls.grep(target).count
        if dupes > 1
          rv << "#{dupes}x #{monster.name}"
        else
          rv << "#{monster.name}"
        end
      end

      golds = rolls.select{|id| [1065, 1067, 1069, 1071, 1073, 1626].include?(id)}.count
      if golds > 0
      	rv << "#{golds}x heroes"
      end

      silvers = rolls.select{|id| [2023, 2024, 2025, 2026, 2027, 2028].include?(id)}.count
      if silvers > 0
      	rv << "#{silvers}x silver eggs"
      end
      m.reply("#{count} pulls: #{rv.join(', ')}")
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
      m.reply "After #{attempts} attempts, you rolled ##{monster.id} #{monster.name}"
    end
  end
end

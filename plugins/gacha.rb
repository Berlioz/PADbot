class Gachapon
  def initialize
    @leaf_eggs = Monster.all.select{|m| m.rem && m.stars == 3}.map(&:id)
    @silver_eggs = Monster.all.select{|m| m.rem && m.stars == 4}.map(&:id)
    @gold_eggs = Monster.all.select{|m| m.rem && m.stars == 5 && m.pantheon.nil?}.map(&:id)
    gods = Monster.all.select{|m| m.rem && m.stars == 5 && m.pantheon}
    @all_gods = gods.map(&:id)
    @pantheons = {}
    gods.each do |god|
      pantheon = god.pantheon
      if @pantheons[pantheon]
        @pantheons[pantheon] << god.id
      else
        @pantheons[pantheon] = [god.id]
      end
    end
  end 

  def roll_gold_eggs(godfest_tags)
    case select_gold_egg_type
      when :gold
        get_monster(@gold_eggs.sample)
      when :god
        choices = @pantheons.select{|k, v| !godfest_tags.include?(k)}.values.flatten
        get_monster(choices.sample)
      when :boosted_god
        choices = @pantheons.select{|k, v| godfest_tags.include?(k)}.values.flatten
        choices.empty? ? get_monster(@all_gods.sample) : get_monster(choices.sample)
    end
  end

  def roll(godfest_tags)
    stars = select_stars
    case stars
      when 3
        get_monster(@leaf_eggs.sample)
      when 4
        get_monster(@silver_eggs.sample)
      when 5
        roll_gold_eggs(godfest_tags)
    end
  end

  def get_monster(id)
    Monster.first(:id => id)
  end

  def select_stars
    #observations
    three = 212
    four = 83
    five = 186
    #sample
    test_string = "3" * three + "4" * four + "5" * five
    test_string.split("").sample.to_i
  end

  def select_gold_egg_type
    #observations
    gold = 57
    god = 18
    boosted_god = 111
    #sample
    test_string = "a" * gold + "b" * god + "c" * boosted_god
    {"a" => :gold, "b" => :god, "c" => :boosted_god}[test_string.split("").sample]
  end
end

class GachaPlugin < PazudoraPluginBase
  def self.helpstring
    "No HELP information defined for #{self.name}. Bug Asterism about it."
  end

  def self.aliases
    ['gacha', 'pull', 'roll', 'rem']
  end

  def initialize
    @gachapon_simulator = Gachapon.new
  end

  def e_a_r_t_h_g_o_l_e_m(s)
    out = ""
    s.each_char do |chr|
      next if chr == " "
      out += chr.upcase
      out += " "
    end
    out.strip
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

  # Horrific. From old Asterbot. Refactor.
  def respond(m, args)
    argv = args ? args.split(" ") : []
    if !argv.last.nil? && argv.last.match(/\+\S+/)
      godfest_flags = argv.last.split(//)[1..-1].map(&:upcase)
      args = args.split("+").first.strip
    else
      godfest_flags = []
    end

    if args == "tags" || args == "list_tags"
      r = "Use +[tags] to denote godfest; for example !pad pull +JGO for a japanese/greek/odins fest.\n"
      r += "Known tags: [R]oman, [J]apanese,  [I]ndian, [N]orse, [E]gyptian, [G]reek, [O]dins, [A]ngels, [D]evils, [C]hinese, [M]etatrons"
      m.reply r
    elsif args.to_i != 0
      gods = []
      args.to_i.times do
        monster = @gachapon_simulator.roll(godfest_flags)
        stars = monster.stars
        type = monster.type
        name = monster.name
        if stars >= 5 && type == "god" && !monster.name.include?("Verche")
          gods << monster.name
        end
      end
      overflow = 0
      if gods.length > 10
        overflow = gods.length - 10
        gods = gods[0..9]
      end
      price = stone_price(args.to_i * 5)
      if gods.length == 0
        r = "You rolled #{args} times (for $#{price}) and got jackshit all. Gungtrolled."
      else
        r = "You rolled #{args} times (for $#{price}) and got some gods:\n"
        r += gods.join(", ")
        if overflow > 0
          r += "...and #{overflow} more"
        end
      end
      m.reply r
    elsif args.nil?
      monster = @gachapon_simulator.roll(godfest_flags)
      stars = monster.stars
      type = monster.type
      name = monster.name

      if name.include?("Golem") || name.include?("Guardian")
        golem = true
        name = e_a_r_t_h_g_o_l_e_m(name)
      end

      if stars >= 5 && type == "god" && !monster.name.include?("Verche")
        msg =  (stars == 6 ? "Lucky bastard!" : "Lucky bastard.")
      elsif stars == 5
        msg = "Meh."
      elsif golem
        msg = "Y O U I D I O T."
      else
        msg = "I just saved you $5."
      end
      r = "You got #{name}, a #{stars}* #{type}. #{msg}"
      m.reply(r)
    else
      regex = false
      identifier = args.strip.downcase
      if identifier.match(/\A\/.*\/\z/)
        regex = true
        identifier = Regexp.new("#{identifier[1..-2]}")
      end
      attempts = 0
      monster = nil
      loop do
        attempts = attempts + 1
        monster = @gachapon_simulator.roll(godfest_flags)
        break if !regex && (monster.name.downcase.include?(identifier) || monster.id == identifier)
        break if regex && (monster.name.downcase.match(identifier) || monster.name.match(identifier))
        m.reply("Unable to roll #{identifier}") and return if attempts == 10000
      end
      price = stone_price(attempts * 5)
      m.reply("After #{attempts} attempts, you rolled a #{monster.name}. (There goes $#{price})")
    end
  end
end

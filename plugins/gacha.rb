class Gachapon
  GODFEST_PANTHEONS = ["O", "M", "S", "Z", "K", "U", "3"]

  def initialize
    @leaf_eggs = Monster.all.select{|m| m.rem && m.stars == 3}.map(&:id)
    @silver_eggs = Monster.all.select{|m| m.rem && m.stars == 4}.map(&:id)
    @gold_eggs = Monster.all.select{|m| m.rem && m.stars = 5 && m.pantheon.nil?}.map(&:id)
    gods = Monster.all.select{|m| m.rem && m.pantheon}
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
    puts @pantheons
  end 

  def godfest_exclusives
    GODFEST_PANTHEONS
  end

  def pantheons
    @pantheons.keys
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
      args = args.split("+").first.strip

      godfest_flags = argv.last[1..-1].upcase.split(',').uniq
      godfest_flags.each do |flag|
        unless flag == '@'q ||  @gachapon_simulator.pantheons.include?(flag)
          r = "Fatal: unknown godfest tag #{flag}. Gachabot tags are now comma-delimited; eg !pad roll +j,g,@"
          m.reply r
          return
        end
      end

      weighted_flags = []
      godfest_flags.each do |flag|
        if flag == "@"
          weighted_flags += @gachapon_simulator.godfest_exclusives
        elsif @gachapon_simulator.godfest_exclusives.include?(flag)
          weighted_flags << flag
        else
          weighted_flags += [flag] * 3
        end
      end
      godfest_flags = weighted_flags
    else
      godfest_flags = []
    end

    if args == "tags" || args == "list_tags"
      r = "Use +[tags] to denote godfest; for example !pad pull +J2,G,O for a japanese 2.0/greek/odins fest.\n"
      r += "Known tags: [R]oman, [J/J2]apanese, [I/I2]ndian, [N]orse, [E/E2]gyptian, [G]reek, [A/A2]ngels, [D]evils, [C]hinese, [H]eroes\n"
      r += "[O]dins, [M]etatrons, [S]onias, G[U]an Yus, [Z]huges, [K]alis, [3] Norns, [@]ll Godfest-Only"
      m.reply r
    elsif args.to_i != 0
      gods = []
      if args.to_i > 100
        m.reply "Not doing >100 rolls at once; apparently you jackasses can't have nice things."
        return
      end
      if args.split(" ").length > 1
        m.reply("#{args.split(' ').last} doesn't seem like a number; remember to prepend godfest tags with a '+'")
        return
      end
      args.to_i.times do
        monster = @gachapon_simulator.roll(godfest_flags)
        stars = monster.stars
        types = monster.types
        name = monster.name
        if monster.pantheon
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
        r += gods.join("; ")
        if overflow > 0
          r += "...and #{overflow} more"
        end
      end
      m.reply r
    elsif args.nil?
      monster = @gachapon_simulator.roll(godfest_flags)
      stars = monster.stars
      types = monster.types
      name = monster.name

      if name.include?("Golem") || name.include?("Guardian")
        golem = true
        name = e_a_r_t_h_g_o_l_e_m(name)
      end

      if stars >= 5 && types.include?("God") && !monster.name.include?("Verche")
        msg =  (stars == 6 ? "Lucky bastard!" : "Lucky bastard.")
      elsif stars == 5
        msg = "Meh."
      elsif golem
        msg = "Y O U I D I O T."
      else
        msg = "I just saved you $5."
      end
      r = "You got #{name}, a #{stars}* #{types.first}. #{msg}"
      m.reply(r)
    else
      regex = false
      identifier = args.strip.downcase
      if identifier.match(/\A\/.*\/\z/)
        regex = true
        identifier = Regexp.new("#{identifier[1..-2]}")
      elsif Monster::NAME_SPECIAL_CASES.keys.include?(identifier)
        target = Monster.fuzzy_search(identifier)
        identifier = target.name.downcase
      end
      attempts = 0
      monster = nil
      loop do
        attempts = attempts + 1
        monster = @gachapon_simulator.roll(godfest_flags)
        break if !regex && (monster.name.downcase.include?(identifier) || monster.id.to_s == identifier)
        break if regex && (monster.name.downcase.match(identifier) || monster.name.match(identifier))
        m.reply("Unable to roll #{identifier}") and return if attempts == 1000
      end
      price = stone_price(attempts * 5)
      m.reply("After #{attempts} attempts, you rolled a #{monster.name}. (There goes $#{price})")
    end
  end
end

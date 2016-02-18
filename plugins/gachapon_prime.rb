require 'open-uri'
require 'openssl'
require 'json'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE  

class Gachapon
  def initialize
    @silvers = []
    @troll_golds = []
    @gods = []
    @gfes = []
    @super_gfes = []

    @pantheons = {}
    @reachable_names = []

    Monster.all.each do |m|
      if m.rem 
        if m.stars == 4
          @silvers << m.id
        elsif m.stars >= 5 && !m.pantheon
          @troll_golds << m.id
        elsif m.stars >= 5 && m.pantheon && m.pantheon != "@"
          @gods << m.id
        end
      end

      if m.pantheon && m.pantheon != "@" && m.stars == 5
        if @pantheons[m.pantheon].nil?
          @pantheons[m.pantheon] = [m.id]
        else
          @pantheons[m.pantheon] << m.id
        end
      end

      if m.pantheon == "@"
        if m.stars == 5
          @gfes << m.id
        else
          @super_gfes << m.id
        end
      end

      @reachable_names << m.name.downcase if (m.pantheon || m.rem) 
    end

    #debug_print
  end 

  def debug_print
    print "SILVERS\n"
    @silvers.each do |id|
      print "##{id} #{Monster.get(id).name}\n"
    end

    print "TROLL GOLDS\n"
    @troll_golds.each do |id|
      print "##{id} #{Monster.get(id).name}\n"
    end

    print "PANTHEONS\n"
    @pantheons.each do |k,v|
      v.each do |id|
        print "(#{k}) ##{id} #{Monster.get(id).name}\n"
      end
    end

    print "GODFEST EXCLUSIVES\n"
    @gfes.each do |id|
      print "##{id} #{Monster.get(id).name}\n"
    end

    print "6* GODFEST EXCLUSIVES\n"
    @super_gfes.each do |id|
      print "##{id} #{Monster.get(id).name}\n"
    end

    print @reachable_names
  end

  def reachable?(name)
    @reachable_names.detect{|n| n.include?(name.downcase)}
  end

  def pantheons
    @pantheons.keys
  end

  #  p(silver) = 0.3, p(troll gold) = 0.35, p(off-godfest) = 0.05,
  #  p(godfest) = 0.22, p(gfe) = 0.06, p (6* gfe) = 0.02
  def roll(godfest_tags)
    test = rand(1000)
    if test < 300
      @silvers.sample
    elsif test < 650
      @troll_golds.sample
    elsif test < 700
      @gods.sample
    elsif test < 920
      pantheon = godfest_tags.sample
      @pantheons[pantheon] ? @pantheons[pantheon].sample : @gods.sample
    elsif test < 980
      @gfes.sample
    else
      @super_gfes.sample
    end
  end
end

class GachaPlugin < PazudoraPluginBase
  def self.helpstring
    "!pad roll: simulate a single pull
!pad roll <monster_name>|\"exact_name\"|#id|/regexp/: pull for a specific monster.
!pad roll n: simulate n pulls
remember to use godfest tags! !pad tags for help"
  end

  def self.aliases
    ['gacha', 'pull', 'roll', 'rem']
  end

  def initialize
    @gachapon_simulator = Gachapon.new
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

  def rolls_for_money(dollars)
    yields = {1 => 1, 5 => 6, 10 => 12, 23 => 30, 44 => 60, 60 => 85}
    stones = 0
    while dollars > 0
      selection = yields.keys.select{|x| x <= dollars}.max
      dollars -= selection
      stones += yields[selection]
    end
    stones / 5
  end

  # determine whether or not asterbot should complement you on rolling something
  def worthwhile?(monster)
    # sonias, colored valks
    if [911, 913, 1088, 972, 982, 1270, 1516].include?(monster.id)
      true
    elsif monster.pantheon
      true
    else
      monster.stars >= 5 && monster.types.include?("God") && !monster.name.include?("Verche")
    end
  end

  def get_box(nick)
    padherder_name = User.fuzzy_lookup(nick).padherder_name rescue nil
    if padherder_name
      j = JSON.parse(open("https://www.padherder.com/user-api/user/#{padherder_name}").read)
      box = j["monsters"].map{|hash| hash["monster"]}.uniq
      box
    else
      nil
    end
  end

  def in_box?(monster, box)
    frontier = [monster.id]
    chain = []
    while frontier.length > 0
      current = Monster.get(frontier.pop)
      chain << current.id
      if current.unevolved
        frontier << current.unevolved unless chain.include?(current.unevolved)
      end
      if current.evolved
        Array(current.evolved).each do |id|
          frontier << id unless chain.include?(id)
        end
      end
    end
    chain = chain.uniq

    chain.each do |id|
      return true if box.include?(id)
    end
    return false
  end

  def respond(m, args)
    argv = args ? args.split(" ") : []
    if !argv.last.nil? && argv.last.match(/\+\S+/)
      args = args.split("+").first.strip

      godfest_flags = argv.last[1..-1].upcase.split(',').uniq
      godfest_flags.each do |flag|
        next if flag == "@"

        unless @gachapon_simulator.pantheons.include?(flag)
          r = "Fatal: unknown godfest tag #{flag}. Gachabot tags are now comma-delimited; eg !pad roll +j,g,@"
          m.reply r
          return
        end
      end
    else
      godfest_flags = []
    end

    p "debug: #{m} with tags #{godfest_flags}"

    if args.to_i != 0 || (args && args[0] == "$" && args[1..-1].to_i != 0)
      m.reply "#{m.user.nick}: #{multi_rolls(args, godfest_flags, m.user.nick)}"
    elsif args.nil? || args.strip.length == 0
      m.reply "#{m.user.nick}: #{single_roll(args, godfest_flags, m.user.nick)}"
    else
      m.reply "#{m.user.nick}: #{roll_for(args, godfest_flags, m.user.nick)}"
    end
    if godfest_flags == []
      m.reply "Silly #{m.user.nick}, you rolled without godfest tags. What'd you expect?"
    end
  end

  def roll_for(args, godfest_flags, nick)
    regex = false
    exact_match = false
    identifier = args.strip.downcase
    if identifier.match(/\A\/.*\/\z/)
      regex = true
      identifier = Regexp.new("#{identifier[1..-2]}")
    elsif Monster::NAME_SPECIAL_CASES.keys.include?(identifier)
      target = Monster.fuzzy_search(identifier)
      identifier = target.name.downcase
    elsif identifier[0] == "#" && identifier[1..-1].to_i != 0
      target = Monster.get(identifier[1..-1].to_i)
      identifier = target.name.downcase
    elsif identifier[0] == '"' && identifier[-1] == '"'
      exact_match = true
      identifier = identifier[1..-2]
      return "-.-" if identifier.length == 0
    end
    unless regex || exact_match
      return "#{args.strip.downcase} doesn't correspond to any known REM monster" unless @gachapon_simulator.reachable?(identifier)
    end

    attempts = 0
    monster = nil
    loop do
      attempts = attempts + 1
      monster = Monster.get(@gachapon_simulator.roll(godfest_flags))
      break if !regex && !exact_match && (monster.name.downcase.include?(identifier))
      break if regex && (monster.name.downcase.match(identifier) || monster.name.match(identifier))
      break if !regex && monster.name.downcase == identifier.downcase
      return ">2000 rolls for #{identifier}" if attempts == 2000
    end
    price = stone_price(attempts * 5)
    log_spending(price)
    "After #{attempts} attempts, you rolled a #{monster.name}. (There goes $#{price})"
  end

  def single_roll(args, godfest_flags, nick)
    monster = Monster.get(@gachapon_simulator.roll(godfest_flags))
    stars = monster.stars
    types = monster.types
    name = monster.name

    if worthwhile?(monster)
      nick = nick
      box = get_box(nick) rescue nil
      if box && in_box?(monster, box)
        msg = "Too bad you already have one."
      else
        msg = "Lucky bastard."
      end
    elsif stars == 5
      msg = "Meh."
    else
      msg = "I just saved you $5."
    end
    log_spending(5)
    "You got #{name}, a #{stars}* #{types.first}. #{msg}"
  end

  def multi_rolls(args, godfest_flags, nick)
    if args[0] == "$"
      args = rolls_for_money(args[1..-1].to_i).to_s
    end
    gods = []
    if args.to_i > 200
      return "Error: too many rolls (>200) requested."
    end
    if args.split(" ").length > 1
      return "#{args.split(' ').last} doesn't seem like a number; remember to prepend godfest tags with a '+'"
    end
    dupes = 0
    box = get_box(nick)
    args.to_i.times do
      monster = Monster.get(@gachapon_simulator.roll(godfest_flags))
      stars = monster.stars
      types = monster.types
      name = monster.name
      if monster.pantheon
        if box
          if in_box?(monster, box)
            dupes += 1
          else
            gods << monster.name
          end
        else
          gods << monster.name
        end
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
      if dupes > 0
        r += ", plus #{dupes} dupes"
      end
    end
    log_spending(price)
    return r
  end

end

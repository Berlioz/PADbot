require 'distribution'

class SkillupPlugin < PazudoraPluginBase
  def self.helpstring
"!pad skillup K N p: Computes the probability of getting K or more skillups in N feeds, with skillup probability p (default = 0.2)
!pad skkillup K/c, Computes how many feeds you'd need to get K skillups with confidence c, !pad skillup 5/0.5"
  end

  def self.aliases
    ['skillup', 'bino', 'cdf', 'binomial']
  end

  def respond(m, args)
    if args.split.length == 1 && args.include?("/")
      reverse_calc(m,args) 
    else
      forward_calc(m,args)
    end
  end

  def reverse_calc(m, args)
    k, c = args.split("/")
    k = k.to_i #desired successes
    c = c.to_f #desired confidence

    if k > 30 || k < 1
      m.reply("desired successes bounded at 1<k<30")
      return
    elsif c < 0.01 || c > 0.99
      m.reply("requested confidence is outside 1% - 99% bounds")
      return
    end

    begin
      (k..250).each do |i|
        failure_chance = Distribution::Binomial::cdf(k-1, i, 0.2)
        success_chance = 1.0 - failure_chance
        if success_chance > c
          m.reply("Gathering #{i} skill-up fodder will give you a #{success_chance.round(3)} chance of #{k} skill-ups.")
          return
        end
      end    
    rescue Exception => e
      m.reply("Bad query: #{e.message}") 
    end
  end

  # Distribution::Binomial::cdf(1, 2, 0.2) = p(<2 successes on 2 feeds at 20%) = 96%

  def forward_calc(m, args)
    argv = args.split(" ")
    if argv.length == 3
      k = argv[0].to_i
      n = argv[1].to_i
      p = argv[2].to_f
    elsif argv.length == 2
      k = argv[0].to_i
      n = argv[1].to_i
      p = 0.2
    else
      reply_on_bad_syntax(m) and return
    end

    if k == 0
      m.reply ("Your odds of getting 0 or more successes is 1, doofus.") and return
    end

    begin
      screwed = Distribution::Binomial::cdf(k-1, n, p)
      ok = (1.0 - screwed).round(3)
      m.reply("On #{n} feeds (p=#{p}), your odds of getting #{k} or more successes is #{ok}.")
    rescue ArgumentError => e
      m.reply("Bad query: #{e.message}") 
    end 
  end
end

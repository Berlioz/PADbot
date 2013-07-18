require 'distribution'

class SkillupPlugin < PazudoraPluginBase
  def self.helpstring
"!pad skillup K, N, p: Computes the probability of getting K or more skillups in N feeds, assuming a skillup probability p. p can be omitted and defaults to 0.2. Example !pad skillup 1, 5, 0.2"
  end

  def self.aliases
    ['skillup', 'bino', 'cdf', 'binomial']
  end

  def respond(m, args)
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

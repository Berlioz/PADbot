# Straight port from Asterbot

class RankPlugin < PazudoraPluginBase
  def self.helpstring
"Usage: !puzzlemon rank (RANK|TO FROM)
Example !puzzlemon rank 60, !puzzlemon rank 100 120
Returns information about a given player rank, or calculates the deltas between them.
Reverse lookup also possible: !puzzlemon rank stamina 100 computes when you will get 100 stamina."
  end

  def self.aliases
    ['rank']
  end

  def respond(m, args)
    argv = args.split(" ")
    if argv.length == 1
      data = Rank.first(:id => argv.first.to_i).attributes
      m.reply("No data for rank #{argv.first}") and return unless data
      r = "Rank #{argv.first}: cost #{data[:cost]}, stamina #{data[:stamina]}, friends #{data[:friends]}, total experience #{data[:exp_total]}, next level in #{data[:exp_next]}"
    elsif argv.length == 2 && ["cost", "stamina", "friends"].include?(argv.first)
      search_stat = argv.first.to_sym
      m.reply("Bad search value #{argv.last}") and return if argv.last.to_i == 0
      search_value = argv.last.to_i
      Rank.all.each do |rank|
        if rank.attributes[search_stat] >= search_value
          m.reply("You will get >= #{search_value} #{search_stat} at rank #{rank.id}") and return
        end
      end
      m.reply("Unable to reverse lookup #{search_value} #{search_stat}") and return
    elsif argv.length == 2
      input = argv.map(&:to_i).sort
      alpha = Rank.first(:id => input.first).attributes
      omega = Rank.first(:id => input.last).attributes
      data_missing = (input.last >= Rank.last.id)

      delta_cost = omega[:cost].to_i - alpha[:cost].to_i
      delta_stamina = omega[:stamina].to_i - alpha[:stamina].to_i
      delta_friends = omega[:friends].to_i - alpha[:friends].to_i

      r = "Ranks #{input.first}-#{input.last}: cost +#{delta_cost}, stamina +#{delta_stamina}, friends +#{delta_friends}"

      if data_missing
        r += ".\nWarning: PDX experience values missing for ranks >= #{Rank.last.id}"
      else
        delta_exp = omega[:exp_total].to_i - alpha[:exp_total].to_i
        kog_stam = delta_exp / 2265
        r += ", experience +#{delta_exp}. That's approximately #{kog_stam} stamina spent on KoG!"
        r += " That's over #{kog_stam / 288} straight days. Have fun!"
      end
    else
      r = "Usage: !pad rank n for data about rank n, !pad rank x y to compute deltas between x and y, !pad <field> n for reverse lookup"
    end
    m.reply(r) 
  end
end

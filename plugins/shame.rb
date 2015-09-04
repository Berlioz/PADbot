require 'time'

class ShamePlugin < PazudoraPluginBase
  def self.aliases
    ["shame", "$$$"]
  end

  def self.helpstring
"!pad shame: How much money has been wasted on asterbot's REM?"
  end

  def respond(m, args)
    total = 0
    first_time = nil
    File.foreach("stones.txt") do |line|
      isotime, dollars = line.split(" ")
      t = Time.iso8601(isotime)
      first_time = t if first_time.nil? || t < first_time
      total += dollars.to_i
    end
    m.reply "Since #{first_time.utc.iso8601.split('T').first} you addicts have 'spent' $#{total} on asterbot..."
  end
end

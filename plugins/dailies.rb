# Daily dungeon commands: dailies, when, settopic
# Based off the Asterbot mk.1 module by nfogravity

require 'open-uri'
require 'nokogiri'

class PDXDailies
  def self.get_dailies(timezone=-8)
	daily_url = "http://www.puzzledragonx.com/en/option.asp?utc=#{timezone}"

	@daily_page = Nokogiri::HTML(open(daily_url))
	event_data = @daily_page.css(".event3")
	event_rewards = @daily_page.css(".limiteddragon")

	rewards = self.parse_daily_dungeon_rewards(event_rewards)

	dailies_array = []
	dailies_array.push(Time.now.strftime "%b %d, %Y")

	hacky_dailies_number = [rewards.length - 1, 3].min # this is NOT optimal and makes some ugly assumptions

	(0..hacky_dailies_number).each do |i|
	  dailies_array.push('|')
	  dailies_array.push(rewards[i])
	  (0..4).each do |j|
        time = "#{event_data[5 * i + j].text}"
        hour = time.split(" ")[0].to_i
        hour = 0 if (hour == 12)
        hour += 12 if time.split(" ")[1] == "pm"
        dailies_array.push(hour.to_s.rjust(2,'0'))
      end
    end

    dailies_array.push("||")
    dailies_array
  end

  def self.parse_daily_dungeon_rewards(daily_page)
    rewards = daily_page.css(".limiteddragon")

    puzzlemon_numbers = []
    frame = 0
    while rewards[frame]
      reward = rewards[frame].children.first.attributes["src"].value.match(/thumbnail\/(\d+).png/)[1]
      puzzlemon_numbers << reward
      frame += 5
    end

    puzzlemon_numbers.map{|id| Monster.first(:id => id.to_i).name rescue "Unknown" }
  end

end

class DailiesPlugin < PazudoraPluginBase
  def self.helpstring
"!pad dailies TZ: Displays a table of all known hourly dungeons for today, from PDX.
TZ can be any integer GMT offset (e.g -3), defaults to GMT-7 Pacific DST"
  end

  def self.aliases
    ['dailies']
  end

  def respond(m, args)
    if args
      timezone = args.to_i      
    else
      timezone = -8
    end
    m.reply(PDXDailies.get_dailies(timezone).join(' '))
  end
end

class TopicPlugin < PazudoraPluginBase
  def self.helpstring
"!pad settopic: Changes the topic of this channel to a summary of today's daily dungeon times.
Uses Pacific time. If it doesn't work, make sure that Asterbot has channel op."
  end

  def self.aliases
    ['settopic', 'topic']
  end

  def respond(m, args)	
    dailies = PDXDailies.get_dailies
    m.channel.topic = (dailies + m.channel.topic.split(' ').drop((m.channel.topic.split(' ').index("||") || -1) + 1)).join(' ')
  end
end

class WhenPlugin < PazudoraPluginBase
  def self.helpstring
"!pad when TZ: Provides a summary of today's daily dungeons for you. Your nick must be known to asterbot with a FC.
TZ can be any integer GMT offset (e.g -3), defaults to GMT-7 Pacific DST"
  end

  def self.aliases
    ['when']
  end

  def respond(m, args)
    if args
      timezone = args.to_i      
    else
      timezone = -8
    end
    user = User.fuzzy_lookup(m.user.nick)
    group_num = user.group_number
 
    dailies_array = PDXDailies.get_dailies(timezone)
    minutes_since_midnight = ((Time.now.to_i - 7*60*60) % 86400)/60
    when_array = [dailies_array[0], "Group", (group_num + 65).chr, dailies_array[1]]
    i = 2
    while dailies_array[i]
      when_array += [dailies_array[i]]
      until_event = 60*dailies_array[i+group_num+1].to_i - minutes_since_midnight
      if until_event > 0
        when_array += "(in #{until_event / 60}:#{(until_event % 60).to_s.rjust(2,'0')}, #{until_event / 10} stamina)"
      elsif until_event > -60
        when_array += ["(now! for #{until_event+60} minutes)"]
      else
        when_array += ["(done)"]
      end

      when_array += ["|"]
      i += 7
    end
    when_array.pop
    m.reply(when_array.join(' '))
  end
end

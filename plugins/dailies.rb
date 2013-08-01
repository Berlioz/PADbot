# Daily dungeon commands: dailies, when, settopic
# Based off the Asterbot mk.1 module by nfogravity

require 'open-uri'
require 'nokogiri'

class PDXDailies
  def self.get_dailies(timezone=-8)
	daily_url = "http://www.puzzledragonx.com/?utc=#{timezone}"

	daily_page = Nokogiri::HTML(open(daily_url))
	event_data = daily_page.xpath("//table[@id='event']").first

    collector = [[], [], [], [], []]
    time_rows = event_data.children.select{|e| e.to_s.include?("metaltime")}
    time_rows.each do |row|
      times = row.children.map{|c| c.children.to_s} 
      #times = ["5 pm", "6 pm", "7 pm", "8 pm", "9 pm"]
      (0..4).each do |i|
        collector[i] << times[i]
      end
    end

	collector
  end

  def self.dungeon_reward
    daily_url = "http://www.puzzledragonx.com/"
	daily_page = Nokogiri::HTML(open(daily_url))
	rewards = daily_page.css(".monstericon")
    rewards.map{|r| r.children.children.last.attributes["title"].value}.first
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
    reward = PDXDailies.dungeon_reward
    groups = PDXDailies.get_dailies(timezone)
    rv = groups.each_with_index.map {|times, i| "#{(i + 65).chr}: #{times.join(' ')}"}
    rv = rv.join(" | ")
    m.reply "Today's dungeon is #{reward}"
    m.reply rv
  end
end

class TopicPlugin < PazudoraPluginBase
  BORDER = " \u2605 "

  def self.helpstring
"!pad settopic: Changes the topic of this channel to a summary of today's daily dungeon times.
Uses Pacific time. If it doesn't work, make sure that Asterbot has channel op."
  end

  def self.aliases
    ['settopic', 'topic']
  end

  def respond(m, args)	
    reward = PDXDailies.dungeon_reward
    groups = PDXDailies.get_dailies(-8)
    report = groups.each_with_index.map {|times, i| "#{(i + 65).chr}: #{times.join(' ')}"}.join(" | ")
    report = "[#{reward}] " + report
    if m.channel.topic.include?(BORDER)
      saved_topic = m.channel.topic.split(BORDER)[0..-2].join(BORDER)
      p "Attempting to set topic to #{saved_topic + BORDER + report}"
      m.channel.topic = saved_topic + BORDER + report
    else
      p "Attempting to set topic to #{m.channel.topic + BORDER + report}"
      m.channel.topic = m.channel.topic + BORDER + report
    end
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
    m.reply "PAD when has not been updated for the new PDX front page yet."

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

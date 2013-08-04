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
    if args
      timezone = args.to_i      
    else
      timezone = -8
    end
    user = User.fuzzy_lookup(m.user.nick)
    group_num = user ? user.group_number : 0
 
    dailies_array = PDXDailies.get_dailies(timezone)
    
    #example: ["10 am", "3 pm", "8 pm"]
    daily_times = dailies_array[group_num]

    result = ["Upcoming Dailies for Group #{(group_num + 65).chr}"]
    daily_times.each do |time_as_string|
      hour, am_or_pm = time_as_string.split
      hour = hour.to_i
      hour += 12 if am_or_pm == "pm"
      
      #Note that Time tracks seconds, so need to convert all numbers to/from seconds.
      start_time = Date.today.to_time + hour * 60 * 60
      minutes_until_start = ((start_time - Time.now)/60).to_i
      
      #Hasn't begun yet
      if minutes_until_start > 0
        result << "(in #{minutes_until_start/60}:#{(minutes_until_start % 60).to_s.rjust(2,'0')}, #{minutes_until_start / 10} stamina)"
      else
        #Currently ongoing
        if minutes_until_start > -60
          result << "(now! for #{minutes_until_start+60} minutes)"
        end
      end
      
    end
    
    m.reply(result.join(' | '))
    
  end
end

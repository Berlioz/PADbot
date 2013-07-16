require 'open-uri'
require 'nokogiri'

class DailiesPlugin < PazudoraPluginBase
  DAILY_URL = "http://www.puzzledragonx.com/en/option.asp?utc=-8"

  def self.helpstring
"!pad dailies: Displays a table of all known hourly dungeons for today, from PDX. Times UTC-7 for now.
!pad dailies me: Displays hourly dungeons for only your own group, if you are registered with Asterbot."
  end

  def self.aliases
    ['dailies']
  end

  def respond(m, args)
    group_only = (args == "me")
    document = Nokogiri::HTML(open(DAILY_URL))
    rewards = parse_daily_dungeon_rewards(document)
    lines = parse_events(document)
    if group_only
      user = User.fuzzy_lookup(m.user.nick)
      unless user
        m.reply "You are not registed with this bot."
        return
      end
      m.reply "Dungeons today are: #{rewards.join(', ')}"
      line = lines.select{|line| line.include?("Group #{user.group}")}.first
      m.reply line
    else
      m.reply "Dungeons today are: #{rewards.join(', ')}"
      lines.each do |line|
        m.reply line
      end
    end
  end

  def parse_daily_dungeon_rewards(daily_page)
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

  def parse_events(daily_page)
    event_data = daily_page.css(".event3")

    lines = []
    (0..4).each do |i|
      group_line = ["Group #{(i + 65).chr}:"]
      frame = 0
      loop do
        break if event_data[i + frame].nil?
        time = "#{event_data[i + frame].text}".ljust(5)
        group_line << time
        frame += 5
      end
      lines << group_line.join(" ")
    end

    lines
  end
end

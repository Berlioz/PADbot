require 'open-uri'
require 'nokogiri'

# TODO: Wait until stable, ditch PDXDailies altoghether, move to stateful parse
class WikiaDailies
  def self.today()
    t = Time.now.getlocal("-08:00")
    "#{t.month}/#{t.day}"
  end

  def self.specials
    wikia = Nokogiri::HTML(open("http://pad.wikia.com/wiki/Template:Urgent_Timetable"))
    table = wikia.xpath("//table[@id='dailyEvents']").first
    today_header = table.xpath("//th").select{|th| th.children.first.to_s.include?(today)}.first
    rows_to_read = today_header.attributes["rowspan"].value.to_i
    starting_index = table.children.index(today_header.parent)
    rows = table.children.slice(starting_index, rows_to_read)

    specials = []
    rows.each do |row|
      unless row.to_s.scan(/\d\d:\d\d/).count == 5
        link = row.children.last.children.first
        specials << link.attributes["title"].value  
      end
    end
    specials
  end

  def self.dungeon_reward
    wikia = Nokogiri::HTML(open("http://pad.wikia.com/wiki/Template:Urgent_Timetable"))
    table = wikia.xpath("//table[@id='dailyEvents']").first
    today_header = table.xpath("//th").select{|th| th.children.first.to_s.include?(today)}.first
    rows_to_read = today_header.attributes["rowspan"].value.to_i
    starting_index = table.children.index(today_header.parent)
    rows = table.children.slice(starting_index, rows_to_read)
    rewards = []

    rows.each do |row|
      if row.to_s.scan(/\d\d:\d\d/).count == 5 
        rewards << row.children.first.children.first.attributes["title"].value rescue nil 
      end
    end
    rewards = rewards.compact.uniq.map do |name|
      name.gsub('Dungeon of ', '').gsub(' Descended', '')
    end
    return rewards.length > 0 ? rewards.join(',') : ""
  end

  def self.get_dailies(timezone = -8)
    wikia = Nokogiri::HTML(open("http://pad.wikia.com/wiki/Template:Urgent_Timetable"))
    table = wikia.xpath("//table[@id='dailyEvents']").first
    today_header = table.xpath("//th").select{|th| th.children.first.to_s.include?(today)}.first
    rows_to_read = today_header.attributes["rowspan"].value.to_i
    starting_index = table.children.index(today_header.parent)
    rows = table.children.slice(starting_index, rows_to_read)

    collector = [[],[],[],[],[]]
    rows.each do |row|
      if row.to_s.scan(/\d\d:\d\d/).count == 5
        (0..4).each do |i|
          collector[i] << row.to_s.scan(/\d\d:\d\d/)[i].split(":").first
        end
      end
    end
    collector
  end

  #Converts "3 pm" or "5 am" to the corresponding time object (local time to bot)
  def self.string_to_time_as_seconds(time_as_string)
    hour = time_as_string.split(":").first
    Date.today.to_time + hour.to_i * 60 * 60
  end
end

# Based off the Asterbot mk.1 module by nfogravity
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
  
  #Converts "3 pm" or "5 am" to the corresponding time object (local time to bot)
  def self.string_to_time_as_seconds(time_as_string)
    hour, am_or_pm = time_as_string.split
    
    #12 am represends 0 hours since midnight, so specialcase
    hour = hour == "12" ? 0 : hour.to_i
    
    hour += 12 if am_or_pm == "pm"
      
    #Note that Time tracks seconds, so need to convert all numbers to/from seconds.
    Date.today.to_time + hour * 60 * 60
  end

end

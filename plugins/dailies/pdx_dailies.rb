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

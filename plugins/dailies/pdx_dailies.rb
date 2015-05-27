require 'open-uri'
require 'nokogiri'

# TODO: Wait until stable, ditch PDXDailies altoghether, move to stateful parse
class WikiaDailies
  SHORTCUTS = {"Super Metal Dragons Descended" => "Metal Supers",
               "Super Gold Dragons Descended" => "Gold Supers",
               "Super Emerald Dragons Descended" => "Emerald Supers",
               "Super Ruby Dragons Descended" => "Ruby Supers",
               "Super Sapphire Dragons Descended" => "Sapphire Supers",
               "Alert! Metal Dragons!" => "Metals",
               "Dungeon of Gold Dragons" => "Golds",
               "Dungeon of Ruby Dragons" => "Rubies",
               "Dungeon of Sapphire Dragons" => "Sapphires",
               "Dungeon of Emerald Dragons" => "Emeralds",
               "Pengdra Village" => "Pengies",
               "Alert! Dragon Plant Infestation!" => "Plants",
               "King Carnival" => "Kings" }

  def initialize(offset=0)
    @today = Time.now.getlocal("-08:00") + (86400 * offset)
    @wikia = Nokogiri::HTML(open("http://padwiki.net/wiki/Homepage/NASchedule"))
  end

  def self.today()
    "#{@today.month}/#{@today.day}"
  end

  def today()
    "#{@today.month}/#{@today.day}"
  end

  def compress(dungeon_name)
    dungeon_name = dungeon_name.tr("_", " ")
    rv = SHORTCUTS[dungeon_name] ? SHORTCUTS[dungeon_name] : dungeon_name
    rv.gsub(" Descended", "")
  end

  def specials
    table = @wikia.xpath("//table").first
    today_header = table.xpath("//th").select{|th| th.children.first.to_s.include?(today)}.first
    rows_to_read = today_header.attributes["rowspan"].value.to_i * 2
    starting_index = table.children.index(today_header.parent)
    rows = table.children.slice(starting_index, rows_to_read)

    specials = []
    rows.each do |row|
      unless row.to_s.scan(/\d\d:\d\d/).count == 5
        link = row.children.last.children.first.attributes["href"].value rescue nil
        unless link.nil?
          result = link.split("/").last.tr('_', ' ')
          specials << result
        end
      end
    end
    specials
  end

  def dungeon_reward
    table = @wikia.xpath("//table").first
    today_header = table.xpath("//th").select{|th| th.children.first.to_s.include?(today)}.first
    rows_to_read = today_header.attributes["rowspan"].value.to_i * 2
    starting_index = table.children.index(today_header.parent)
    rows = table.children.slice(starting_index, rows_to_read)
    rewards = []

    rows.each do |row|
      if row.to_s.scan(/\d\d:\d\d/).count == 5 
        rewards << row.children[1].children.first.attributes["title"].value rescue nil 
      end
    end
    rewards = rewards.compact.map {|name| compress(name)}
    return rewards.length > 0 ? rewards.join(', ') : ""
  end

  def get_dailies(timezone = -8)
    table = @wikia.xpath("//table").first
    today_header = table.xpath("//th").select{|th| th.children.first.to_s.include?(today)}.first
    rows_to_read = today_header.attributes["rowspan"].value.to_i * 2
    starting_index = table.children.index(today_header.parent)
    rows = table.children.slice(starting_index, rows_to_read)

    collector = [[],[],[],[],[]]
    rows.each do |row|
      if row.to_s.scan(/\d\d:\d\d/).count == 5
        (0..4).each do |i|
          time = row.to_s.scan(/\d\d:\d\d/)[i]
          display_value = time.split(":").first
          display_value += ":30" if time.split(":").last.include?("30")
          collector[i] << display_value
        end
      end
    end
    collector
  end

  #Converts "3 pm" or "5 am" to the corresponding time object (local time to bot)
  def string_to_time_as_seconds(time_as_string)
    hour = time_as_string.split(":").first
    Date.today.to_time + hour.to_i * 60 * 60
  end
end
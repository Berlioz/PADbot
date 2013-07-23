require 'open-uri'
require 'json'

class WiresharkPlugin < PazudoraPluginBase

  def self.helpstring
    "!pad wirshark URL: Analyzes a sneak_dungeon API response for dungeon drops. Obtain via tcpdump/Wireshark and upload to a URL with Gist or Dropbox or something."
  end

  def self.aliases
    ['wireshark', 'drops']
  end

  def respond(m, args)
    begin
      json = JSON.parse(open(args).read)
    rescue Errno::ENOENT
      m.reply "The provided URL is invalid/not a PAD JSON object."
      return
    rescue JSON::ParserError => e
      m.reply "Error trying to parse JSON: #{e.message}"
      return
    end

    floors = json["waves"]
    drops = []
    floors.each do |floor_hash|
      floor_num = floor_hash["seq"]
      drop = floor_hash["monsters"].select{|m| m["item"] != 0}
      next if drop.empty?
      drop = drop.first
      if drop["item"] == "900"
        drop_message = "#{drop["inum"]} Gold"
      else
        monster = Monster.first(:id => drop["item"].to_i)
        level = drop["lv"]
        drop_message = "#{monster} (lv #{level})"
      end
      drops << drop_message
    end
    
    if drops.empty?
      m.reply "Dungeon will have zero (0) drops. Bad luck."
    else
      m.reply "Drops from dungeon:"
      m.reply drops.join(", ")
    end
  end

end

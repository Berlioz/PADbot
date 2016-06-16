require 'time'
require 'cgi'

require 'pry'

class MiscPlugin
  include Cinch::Plugin

  match /cotton/i, method: :boldstrategy
  match /iriya/i, method: :iriya
  match /showme/i, method: :morpheus

  match /google (.+)/, method: :goog
  match /image (.+)/, method: :image
  match /gis (.+)/, method: :image
  
  listen_to :channel

  def morpheus(m)
    m.reply("http://i.imgur.com/G7HWIom.gif")
  end

  def boldstrategy(m)
    m.reply("http://i.imgur.com/XDS9B0x.gif")
  end

  def iriya(m)
    m.reply("http://i.imgur.com/AimVZW4.gif")
  end

  API = 'AIzaSyCqLavH2wQHA9k5QkE-uqu1-eawRJI2HMo'
  CX = '002768011199832670326:upzmqblp3im'

  def listen(m)
    msg = m.params[1]
    r = /www\.youtube.com\/watch\?v=(\w+)/
    if r === msg
      video_id = msg.scan(r).first.first
      query =  "https://www.googleapis.com/youtube/v3/videos?part=snippet%2CcontentDetails%2Cstatistics%2CrecordingDetails&id=#{video_id}&key=#{API}"
      res = JSON.parse(Nokogiri::HTML(open(query)))["items"].first # hash
      title = res["snippet"]["title"].encode("ISO-8859-1")
      times = get_time_str(res["contentDetails"]["duration"])
      views = res["statistics"]["viewCount"]
      likes = res["statistics"]["likeCount"]
      dislikes = res["statistics"]["dislikeCount"]
      m.reply("#{times} - #{title} - #{views} views, #{likes}+/#{dislikes}-")
    end
  end

  def get_time_str(ts)
    lengths = ts.scan(/(\d+)/).flatten.reverse
    keys = {0 => "s", 1 => "m", 2 => "h", 3 => "d", 4 => "w"}
    output = []
    if lengths.length == 1
      "#{lengths[0]}s"
    elsif lengths.length == 2
      "#{lengths[1]}:#{lengths[0]}"
    else
      lengths.each_with_index do |l, i|
        output << "#{l}#{keys[i]}"
      end
      output.reverse.join(" ")
    end
  end

  def image(m, query)
    url = "https://www.googleapis.com/customsearch/v1?key=#{API}&q=#{CGI.escape(query)}&cx=#{CX}&&searchType=image&fields=items(link)&safe=high"
    p url
    res = JSON.parse(Nokogiri::HTML(open(url)))
    m.reply(res["items"].map {|x| x["link"]}.first)
  end

  def search(query)
    url = "http://www.google.com/search?q=#{CGI.escape(query)}"
    res = Nokogiri::HTML(open(url)).at("h3.r")

    title = res.text
    link = res.at('a')[:href]
    desc = res.at("./following::div").children.first.text
    CGI.unescape_html "#{title} - #{desc} (#{link})"
  rescue
    "No results found"
  end

  def goog(m, query)
    m.reply(search(query))
  end
end


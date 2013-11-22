require 'open-uri'
require 'nokogiri'

class NewsPlugin < PazudoraPluginBase
  SEP = " | "
  PDX = "http://www.puzzledragonx.com/"

  def initialize
    super
  end

  def self.aliases
    ['news']
  end

  def self.helpstring
    "!pad news: displays last known news bulletin from PDX
!pad news register: register yourself to recieve IRC pings on new news"
  end

  def tick(current_time, channels)
    @@last_pinged_at ||= {}
    puts "*****"
    puts @@last_pinged_at
    channels.each do |channel|
      if @@last_pinged_at[channel.name]
        parse_pdx
        if get_log.last[:time].to_i > @@last_pinged_at[channel.name]
          targets = []
          channel.users.keys.each do |u|
            if registered_users.include?(User.fuzzy_lookup(u.nick))
              targets << u unless targets.include? u
            end
          end
          channel.send("PDX has hosted a new headline: #{get_log.last[:headline]}")
          channel.send('^ ' + targets.map(&:nick).join(', '))
        end
        @@last_pinged_at[channel.name] = Time.now.to_i
      else
        @@last_pinged_at[channel.name] = Time.now.to_i
      end
    end
  end

  def respond(m,args)
    if args == "parse"
      parse_pdx
      m.reply "Done!"
    elsif args == "register"
      user = User.fuzzy_lookup(m.user.nick)
      m.reply "You're not registered with Asterbot" and return unless user
      user.add_plugin_registration(NewsPlugin)
      m.reply "OK, registered."
    elsif args.to_i > 0
      n = args.to_i
      all_news = get_log
      return unless (all_news.length >= n && n < 8)
      start = -1 - n + 1
      all_news[start..-1].each do |news|
        m.reply(news[:headline] + "(#{news[:url]})")
      end
    else
      m.reply(get_log.last[:headline] + "(#{get_log.last[:url]})")
    end
  end

  def parse_pdx
    known_headlines = get_log.map{|h| h[:headline]}
    write_cache = []
    page = Nokogiri::HTML.parse(open(PDX))
    news_table = page.xpath("//table[@id='event']").detect{|t| t.to_s.include? "News"}
    news_table.children[1..-1].each do |news|
      link = news.children[2].children.first
      headline = link.children.first.to_s
      headline = headline.split(" * New").first
      url = PDX + link.attributes["href"].value
      unless known_headlines.include? headline
        write_cache << {:time => Time.now, :headline => headline, :url => url}
      end
    end
    write_cache.reverse.each do |news|
      write_to_log(news[:time], news[:headline], news[:url])
    end
  end

  def get_log
    f = File.new('data/headlines', 'r')
    posts = f.read.split("\n")
    posts.map do |rawstring|
      epoch, headline, url = rawstring.split(SEP)
      time = Time.at(epoch.to_i)
      {:time => time, :headline => headline, :url => url}
    end
  end

  def write_to_log(time, headline, url)
    f = File.new('data/headlines', 'a+')
    f.write("#{time.to_i}" + SEP + headline + SEP + url + "\n")
    f.close
  end
end

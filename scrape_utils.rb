# from pry, scrape_monster(id) to add it to the database

require 'open-uri'
require 'nokogiri'
require 'pry'
require 'json'
require 'data_mapper'
require 'yaml'
Dir.glob("models/*.rb").each {|x| require_relative x}

# PORTED FROM OLD ASTERBOT. NOT MAINTAINABLE CODE
# todo: burn it to the ground

class Puzzlemon
  PUZZLEMON_BASE_URL = "http://www.puzzledragonx.com/en/"
  TYPES = ["Dragon", "Balanced", "Physical", "Healer", "Attacker", "God", "Devil", "Evo Material", "Enhance Material", "Protected"]

  # given an XP curve page, return the XP required to hit a level from 0
  def self.xp_at_level(curve_page, level)
    all_elements = curve_page.xpath("//table[@id='tablechart']//tbody//td")
    rows = curve_page.xpath("//table[@id='tablechart']//tbody//td[@class='blue']")
    row_index = all_elements.index(rows.select{|h| h.text == level.to_s}.first)
    all_elements[row_index + 1].text.to_i
  end

  def self.xp_to_level(curve_page, from, to)
    begin
      xp_at_level(curve_page, to) - xp_at_level(curve_page, from)
    rescue NoMethodError
      nil
    end
  end

  def initialize(identifier, gacha=false)
    if gacha
      @doc = gacha_page
    else
      @doc = pdx_page_from_identifier(identifier)
    end
  end

  def gacha_page
    Nokogiri::HTML.parse(open(GACHA_URL).read)
  end

  def valid?
    !@doc.nil?
  end

  def noko
    @doc
  end

  def experience_delta(from)
    links = @doc.xpath("//a").map{|element| element.attributes["href"]}.compact
    curve_link = links.select{|link| link.value.include?("experiencechart")}.first
    curve_page = Nokogiri::HTML(open(PUZZLEMON_BASE_URL + curve_link.value))
    Puzzlemon.xp_to_level(curve_page, from, max_level)
  end

  # given an id or monster name, uses pdx's fuzzy matcher to find the pdx
  # page for the referenced monster. Returns nil if the fuzzy matcher returns
  # nothing e.g meteor dragon what the fuck seriously jesus christ
  def pdx_page_from_identifier(identifier)
    search_url = PUZZLEMON_BASE_URL + "monster.asp?n=#{URI.encode(identifier)}"
    info = Nokogiri::HTML(open(search_url))

    #Bypass puzzledragonx's "default to meteor dragon if you can't find the puzzlemon" mechanism
    meteor_dragon_id = "211"
    if info.css(".name").children.first.text == "Meteor Volcano Dragon" && !(identifier.start_with?("Meteor") || identifier == meteor_dragon_id)
      return nil
    else
      return info
    end
  end

  def pdx_descriptor
    @doc.css("meta [name=description]").first.attributes["content"].text
  end

  # grab the name of a monster from its page the stupid way
  def name
    @doc.css(".name").children.first.text
  end

  # find the URL of the image of the monster, and parse it for the monster's id
  def id
    avatar_image = @doc.xpath("//div[@class='avatar']").first.children.first
    path = avatar_image.attributes["src"].value
    /img\/book\/(\d+)\.png/.match(path)[1]
  end

  # given a pazudora info page, find the max level of the monster
  def max_level
    lookup_stat("Level:").last
  end

  def max_xp
    match = @doc.to_s.scan(/((\d|,)+) Exp to max/)
    begin
      return match[0][0].tr(',','').to_i
    rescue NoMethodError
      return 0
    end
  end

  def stat_line(stat_name)
    minmax = lookup_stat(stat_name + ":")
    "#{minmax.first}-#{minmax.last}"
  end

  def lookup_stat(stat_name)
    row = @doc.xpath("//table[@id = 'tablestat']//td[@class = 'title']").
        select{|x| x.text == stat_name}.first
    siblings = row.parent.children
    [siblings[1].text.to_i, siblings[2].text.to_i]
  end

  def awakenings
    nodes = @doc.xpath("//td[@class='awoken1']")
    nodes.map{|n| n.to_s.match(/awokenskill.asp\?s=(\d+)/)[1].to_i}
  end

  def skill
    link = @doc.xpath("//a").select{|link| link.attributes["href"] && link.attributes["href"].
        value.match(/\Askill.asp?/)}.first
    return "No active skill.\n" if link.nil?
    name = link.children.first.text
    lines = link.parent.parent.parent.children.map(&:text)
    index = lines.index("Skill:#{name}")

    skillname = lines[index].split(":").last
    cooldowns = lines.select{|l| l.include? "Cool Down"}.first
    cooldowns = cooldowns.scan(/Cool Down:(\d+) Turns \( (\d+) minimum \)/).first
    cooldowns = "(#{cooldowns.last}-#{cooldowns.first} turns)"

    effect_line = lines.detect{|l| l.include?("Effects:")}
    effect = effect_line.split(":").last

    "(Active) #{skillname}: #{effect.strip} #{cooldowns}\n"
  end

  def leaderskill
    link = @doc.xpath("//a").select{|link| link.attributes["href"] && link.attributes["href"].
        value.match(/\Aleaderskill.asp?/)}.first
    return "No leader skill.\n" if link.nil?
    name = link.children.first.text
    lines = link.parent.parent.parent.children.map(&:text)
    index = lines.index("Leader Skill:#{name}")
    if lines[index + 2]
      effect = lines[index + 2].tr(')', '').tr('(', '')
    end
    if effect.nil? || effect == ""
      effect = lines[index + 1].split(":").last
    end

    "(Leader) #{name}: #{effect}"
  end

  def stars
    @doc.xpath("//div[@class='stars']//img").count
  end

  def element
    desc = pdx_descriptor
    desc.scan(/is a (.*?) element monster/)[0][0]
  end

  def cost
    desc = pdx_descriptor
    desc.scan(/costs (\d+?) units/)[0][0]
  end

  def type
    desc = pdx_descriptor
    basic_type = desc.scan(/stars (.*?) monster/)[0][0]

    # attempt to retrieve a second type from PDX
    text_links = @doc.xpath("//a").map{|x| x.children ? x.children.detect{|y| y.is_a? Nokogiri::XML::Text}.to_s : nil }.compact
    attested_types = text_links.select{|t| TYPES.include?(t)}

    attested_types.uniq
  end

  def get_puzzledex_description
    r = "No. #{id} #{name}, a #{stars}* #{element} #{type} monster.\n"
    r += "Deploy Cost: #{cost}. Max level: #{max_level}, #{max_xp} XP to max.\n"
    r += "HP #{stat_line("HP")}, ATK #{stat_line("ATK")}, RCV #{stat_line("RCV")}, BST #{stat_line("Total")}\n"
    r += "#{skill}"
    r += "#{leaderskill}"
    r
  end
end

def chain(pdx)
  info = pdx.noko

  # Compute the ID numbers of the puzzlemons in this particular chain
  chain_divs = info.xpath("//td[@class='evolve']//div[@class='eframenum']")
  chain_members = chain_divs.map{|div| (div.children.first.text)}
  chain_members.map(&:to_i)
end

def mats(pdx)
  info = pdx.noko

  # Compute the ID numbers of the puzzlemons in this particular chain
  chain_divs = info.xpath("//td[@class='evolve']//div[@class='eframenum']")
  chain_members = chain_divs.map{|div| div.children.first.to_s}

  # Compute the location of the current puzzlemon in the chain
  requirements = info.xpath("//td[@class='require']")
  busty_requirements = info.xpath("//td[@class='finalevolve nowrap']")
  ultimate_count = busty_requirements.count
  index = chain_members.index(pdx.id)

  if index == requirements.length && ultimate_count > 0
    busty_requirements.map{|r| evo_material_list(r)}
  elsif index.nil? || requirements.nil? || index >= requirements.length
    []
  else
    evo_material_list(requirements[index])
  end
end

def evo_material_list(td)
  material_elements = td.children.select{|element| element.name == "a"}
  material_elements.map do |element|
    element.children.first.attributes["title"].value
  end
end

def exp_curve(pdx)
    links = pdx.noko.xpath("//a").map{|element| element.attributes["href"]}.compact
    curve_link = links.select{|link| link.value.include?("experiencechart")}.first
    return nil if curve_link.nil?
    out = curve_link.value.scan(/.*?(\d+).*?/).first.first
  out
end

def update_book(start = 0)
  Monster.all.each do |m|
    next unless m.id > start
    p "updating ##{m.id} #{m.name}..."
    begin
      scrape_monster(m.id, :update)
    rescue ArgumentError => e
      p "ERROR updating! #{e.message}"
    end
  end
end

def scrape_new_monsters
  new_ids = new_monsters
  p "Creating new entries for #{new_ids.count} monsters..."
  new_ids.each do |id|
    data = scrape_monster(id)
    p "Created #{data}"
  end
end

def new_monsters
  data = open("http://www.puzzledragonx.com/en/monsterbook.asp").read
  all_ids = data.scan(/monster.asp\?n=(\d+)/).flatten.map(&:to_i)
  all_ids.select{|id| Monster.get(id).nil?}
end

def scrape_monster(n, mode = :create)
  pdx = Puzzlemon.new(n.to_s)
    name = pdx.name
    max_level = pdx.max_level
    max_xp = pdx.max_xp.to_i
    skill_text = pdx.skill
    leader_text = pdx.leaderskill
    awakenings = pdx.awakenings
    stars = pdx.stars
    element = pdx.element
    cost = pdx.cost.to_i
    types = pdx.type
    hp_min = pdx.lookup_stat("HP:").first
    hp_max = pdx.lookup_stat("HP:").last
    atk_min = pdx.lookup_stat("ATK:").first
    atk_max = pdx.lookup_stat("ATK:").last
    rcv_min = pdx.lookup_stat("RCV:").first
    rcv_max = pdx.lookup_stat("RCV:").last
    bst_min = pdx.lookup_stat("Total:").first
    bst_max = pdx.lookup_stat("Total:").last
    evo_chain = chain(pdx)
    evo_mats = mats(pdx)
    curve = exp_curve(pdx)
    out = {
      :id => n,
      :name => name,
      :max_level => max_level,
      :max_xp => max_xp,
      :skill_text => skill_text,
      :leader_text => leader_text,
      :awakenings => awakenings,
      :stars => stars,
      :element => element,
      :cost => cost,
      :types => types,
      :hp_min => hp_min,
      :hp_max => hp_max,
      :atk_min => atk_min,
      :atk_max => atk_max,
      :rcv_min => rcv_min,
      :rcv_max => rcv_max,
      :bst_min => bst_min,
      :bst_max => bst_max,
      :evo_chain => evo_chain,
      :materials => evo_mats,
      :curve => curve
    }
    out[:materials] = out[:materials].first if out[:materials].first.is_a? Array
    out[:materials] = out[:materials].map{|s| s.gsub(/[^0-9]/,"").to_i}
    chain = out[:evo_chain]
    own_index = chain.index(n)
    out[:unevolved] = own_index == 0 ? nil : chain[own_index - 1] unless own_index.nil?
    out[:evolved] = own_index == chain.length - 1 ? nil : chain[own_index + 1] unless own_index.nil?
    data = out.delete_if{|k,v| k == :evo_chain}
    case mode
      when :create
        Monster.create!(data)
      when :update
        m = Monster.get(n)
        m.update!(data)
      when :test
        #noop
    end
    out
end

config = YAML.load(File.read("database_config.yaml"))
DataMapper.setup(:default, config)
DataMapper.finalize

binding.pry

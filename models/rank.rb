require 'nokogiri'
require 'open-uri'

class Rank
  RANK_TABLE_URL = "http://www.puzzledragonx.com/en/rankchart.asp"
  include DataMapper::Resource

  property :id, Integer, :key => true
  property :stamina, Integer
  property :cost, Integer
  property :friends, Integer
  property :exp_total, Integer
  property :exp_next, Integer

  def scrape_from_pdx!
    ranks = Nokogiri::HTML.parse(open(RANK_TABLE_URL).read)
    rows = ranks.xpath("//tr").select{|a| a.children.first.to_s.include? "class=\"blue"}
    rows[1..-1].each do |row|
      cells = row.children
      level = cells[0].children.to_s.to_i
      cost = cells[6].children.to_s.to_i
      stamina = cells[7].children.to_s.to_i
      friends = cells[8].children.to_s.to_i
      exp_total = cells[10].children.to_s.to_i
      exp_next = cells[9].children.to_s.to_i
      attributes = {cost:cost,
                   stamina:stamina,
                   friends:friends,
                   exp_total:exp_total,
                   exp_next:exp_next}
      self.first_or_create(:id => level).update(attributes)
    end
    rv
  end
end
class Awakening
  include DataMapper::Resource

  property :id, Integer, :key => true
  property :name, String
  property :effect, Text

  BASE_URL = "http://www.puzzledragonx.com/en/awokenskill.asp?s="

  def self.lookup(id)
    self.first(:id => id) || self.scrape(id)
  end

  def self.scrape(id)
    unless self.first(:id => id)
      @doc = Nokogiri::HTML(open(BASE_URL + id.to_s))
      lines = @doc.xpath("//td[@class='value-end']")
      name = lines.first.children.first.to_s
      effect = lines.last.children.first.to_s
      self.create!(:id => id, :name => name, :effect => effect)
    end  
  end
end

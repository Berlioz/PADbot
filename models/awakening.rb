require 'levenshtein'

class Awakening
  include DataMapper::Resource

  property :id, Integer, :key => true
  property :name, String
  property :effect, Text

  BASE_URL = "http://www.puzzledragonx.com/en/awokenskill.asp?s="

  def self.lookup(id)
    self.first(:id => id) || self.scrape(id)
  end

  def self.find_by_name(n)
    self.edit_distance_search(n)
  end

  def self.edit_distance_search(identifier)
    limit = (identifier.length) / 3
    limit = 3 if limit < 3
    names = self.all.map(&:name)
    choice = names[names.map{|current| Levenshtein.distance(identifier.downcase, current.downcase)}.each_with_index.min.last]
    return nil if Levenshtein.distance(identifier.downcase, choice.downcase) > limit
    self.first(:name => choice)
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

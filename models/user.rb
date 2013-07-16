class User
  include DataMapper::Resource

  property :id, Serial
  property :registered_name, String
  property :irc_aliases, Object
  property :pad_code, Integer
  property :is_admin, Boolean

  def self.fuzzy_lookup(identifier)
    user = self.first(:registered_name => identifier)
    if user.nil?
      self.all.each do |current|
        if current.irc_aliases.include?(identifier)
          user = current && break
        end
      end
    end
    user
  end

  def to_s
    registered_name
  end
end

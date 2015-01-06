class User
  include DataMapper::Resource

  property :id, Serial
  property :registered_name, String
  property :irc_aliases, Object
  property :pad_code, Integer
  property :is_admin, Boolean
  property :plugin_registrations, Object
  property :padherder_name, String

  def self.registered_with_plugin(plugin)
    self.all.select{|u| u.plugin_registrations.include?(plugin.class.name)}
  end

  def self.fuzzy_lookup(identifier)
    user = self.first(:registered_name => identifier)

    if user.nil?
      self.all.each do |current|
        if (current.irc_aliases.map(&:downcase) + [current.registered_name.downcase]).include?(identifier.downcase)
          return current
        end
      end
    end
    user
  end

  def to_s
    registered_name
  end

  def group_number
    Integer(pad_code.to_s.split('')[2]) % 5
  end

  def group
    {0 => 'A', 1 => 'B', 2 => 'C', 3 => 'D', 4 => 'E'}[group_number]
  end

  def add_plugin_registration(plugin)
    unless plugin_registrations.include?(plugin.class.name)
      self.update!({:plugin_registrations => plugin_registrations + [plugin.class.name]})
     end
  end
end

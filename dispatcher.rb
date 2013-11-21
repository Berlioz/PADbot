class Dispatcher
  include Cinch::Plugin

  match /pazudora ([\w-]+) *(.+)*/i, method: :execute
  match /stupidpuzzledragonbullshit ([\w-]+) *(.+)*/i, method: :execute
  match /stupiddragonpuzzlebullshit ([\w-]+) *(.+)*/i, method: :execute
  match /p&d ([\w-]+) *(.+)*/i, method: :execute
  match /pad ([\w-]+) *(.+)*/i, method: :execute
  match /puzzlemon ([\w-]+) *(.+)*/i, method: :execute
  match /init/, method: :init_reactor
  match /clockup/, method: :init_reactor

  def initialize(*args)
    super
    @plugins = PazudoraPluginBase.descendants
    @reactor_targets = @plugins.select {|p| p.instance.respond_to?(:tick)}
    @@reactor_started ||= false
  end

  def init_reactor(m=nil, cmd=nil, args=nil)
    if @reactor_started
      m.reply "Event reactor already started." and return
    end
    @reactor_started = true
    m.reply "Starting event reactor!"
    p "Initializing reactor for: #{@reactor_targets.map(&:name).join(',')}"

    while true do
      p "Reactor firing: #{Time.now}"
      @reactor_targets.each do |p|
        begin
          p.instance.tick(Time.now, self.bot.channels)
        rescue Exception => e
          print "Exception for #{p.name}: #{e}"
        end
      end
      sleep(60)
    end
  end

  def select_plugin(cmd)
    @plugins.each do |plugin|
      return plugin if plugin.aliases.include?(cmd)
    end
    nil
  end

  def execute(m, cmd, args)
    plugin = select_plugin(cmd.downcase.chomp)
    return if plugin.nil?
    plugin.instance.respond(m, args)
  end
end

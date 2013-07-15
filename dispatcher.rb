class Dispatcher
  include Cinch::Plugin

  match /pazudora ([\w-]+) *(.+)*/i, method: :execute
  match /stupidpuzzledragonbullshit ([\w-]+) *(.+)*/i, method: :execute
  match /stupiddragonpuzzlebullshit ([\w-]+) *(.+)*/i, method: :execute
  match /p&d ([\w-]+) *(.+)*/i, method: :execute
  match /pad ([\w-]+) *(.+)*/i, method: :execute
  match /puzzlemon ([\w-]+) *(.+)*/i, method: :execute

  def initialize(*args)
    super
    @plugins = PazudoraPluginBase.descendants
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

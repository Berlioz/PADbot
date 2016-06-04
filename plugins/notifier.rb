require 'firebase'

class NotifierPlugin
  include Cinch::Plugin

  listen_to :channel
  timer 60, method: :clear
  match /notify ([\w-]+) *(.+)*/i, method: :notify
  match /alarm (\d+) *(.+)*/i, method: :alarm

  def initialize()
    @ignore_list = []
    @firebase = Firebase.new
  end

  def listen(m)
  	nick = m.user.nick.to_s
  	channel = m.channel.to_s
    return if @ignore_list.include?(nick)
    @ignore_list << nick

    queued_events = @firebase.user_events(nick, channel)
    ignored_events = []

    queued_events.each do |event|
      delivery_time = event[:deliver_at]
      if delivery_time == "now"
      	if nick == event[:sender]
          m.reply("#{nick}: reminder: '#{event[:message]}'")
      	else
          m.reply("#{nick}: message from #{event[:sender]}: '#{event[:message]}'")
        end
      else
        ignored_events << event
      end
    end

    @firebase.update(nick, ignored_events)
  end

  def clear
    @ignore_list = []
  end

  def notify(m, user, message)

  end

  def alarm(m, time, message)

  end
end

# uri = FIREBASE = 'https://crackling-heat-3529.firebaseio.com/'
class Firebase
  def initialize()
    @uri = File.read("firebase").chomp
    @firebase = Firebase::Client.new(@uri)
  end

  def enqueue(user, sender, message, channel, delay="now")
    @firebase.push("#{user}#{channel}", {:msg => message, :deliver_at => delay, :sender => sender})
  end

  def user_events(user, channel)
    @firebase.get("#{user}#{channel}").values
  end

  def update(user, channel unused_events)
    @firebase.set("#{user}#{channel}", unused_events)
  end
end
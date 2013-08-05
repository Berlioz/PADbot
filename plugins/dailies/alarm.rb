require 'timers'

class DailyAlarmPlugin < PazudoraPluginBase
  def self.helpstring
"!pad clockme, clockup: Sets timers for each daily, and adds users to be PMed for their group when it begins."
  end

  def self.aliases
    ['clockup', 'clockme']
  end

  def respond(m, args)
    if !@alarm
      m.reply "Starting alarms."
      initialize_alarm(m.channel)
    end
    
    user = User.fuzzy_lookup(m.user.nick)
    if user
      @alarm.add_user(m.user, user.group_number)
      m.reply "User #{m.user.nick} added to alert list."
      
    else
      m.reply "User #{m.user.nick} not registered."
    end
    
    unless @started
      @started = true
      @alarm.start_clocks
    end
  end
  
  def initialize_alarm(channel)
    @alarm ||= DailyAlarm.new(channel)
    @started ||= false
  end
end

class DailyAlarm
  def initialize(channel)
    @channel = channel
    @notification_list = [[], [], [], [], []]
  end
 
  def add_user(user, group_num)
    @notification_list[group_num] << user unless @notification_list[group_num].member?(user)
  end
 
  def alert(group_num, reward)
    group = (group_num + 65).chr
    @channel.send "Daily alert for group #{group} (#{reward})!"
    @notification_list[group_num].each do |user|
      user.send "Your daily (group #{group}, #{reward}) is starting now."
    end
  end
  
  def start_clocks
    @timers = Timers.new

    reward = ::PDXDailies.dungeon_reward
    dailies_array = ::PDXDailies.get_dailies
    dailies_array.each_with_index do |daily_times, group_num|
      daily_times.each do |time_as_string|
        start_time = ::PDXDailies.string_to_time_as_seconds(time_as_string)
        seconds_until_start = start_time - Time.now
        if seconds_until_start > 0
          @timers.after(seconds_until_start) { self.alert(group_num, reward) }
        end
      end      
    end
    
    loop do
      if !@timers.wait_interval
        break
      end
      sleep @timers.wait_interval
      @timers.fire
    end
  end
end

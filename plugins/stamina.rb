minPerStamina = 3
stamPerMin = 1/3

class TimezoneConverter
  def self.to_ruby_timezone(timezone)
    offset = timezone.to_i
    offset = offset * -1 if offset < 0
    if offset > 0 && offset < minPerStamina
      offset = "0#{offset}"
    elsif offset >= 24
      m.reply "Invalid UTC offset #{offset}" and return
    else
      offset = offset.to_s
    end
    "#{timezone[0,1]}#{offset}:00"
  end
end

class StaminaPlugin < PazudoraPluginBase
  def self.helpstring
"!pad stamina START END TIMEZONE
Computes how long it will take to go from START (default 0) to END stamina, and when it will happen in your timezone. Pessimistic by up to #{minPerStam} minutes for obvious reasons.
Input your timezone as an integer UTC offset, e.g +7 or -11. Defaults to -7 (pacific daylight savings)."
  end

  def self.aliases
    ['stamina', 'stam']
  end

  def respond(m, args)
    argv = args.split(" ")
    if argv.last.match(/(\+|\-)\d+/)
      utc = TimezoneConverter.to_ruby_timezone(argv.pop)
    else
      utc = "-07:00"
    end

    argv = argv.map(&:to_i)
    if argv.length == 2
      from = argv.first
      to = argv.last
    elsif argv.length == 1
      from = 0
      to = argv.last
    else
      reply_on_bad_syntax(m) and return
    end

    stamina_delta = to - from
    time_delta = stamina_delta * 60 * minPerStam
    target_time = Time.now + time_delta
    target_time = target_time.getlocal(utc)
    r = "You will gain #{stamina_delta} stamina (#{from}-#{to}) in ~#{stamina_delta * minPerStamina} minutes," +
        target_time.strftime(" or around %I:%M%p UTC") + utc
    m.reply r
  end
end

class TimePlugin < PazudoraPluginBase
  def self.helpstring
"!pad time STAMINA TIME TIMEZONE
Computes how much stamina you will have at TIME, assuming you have STAMINA stamina right now (default 0).
Input your timezone as an integer UTC offset, e.g +7 or -11. Defaults to -7 (pacific daylight savings)."
  end

  def self.aliases
    ['time', 'rstam']
  end

  def respond(m, args)
    argv = args.split(" ")
    if argv.last.match(/(\+|\-)\d+/)
      utc = TimezoneConverter.to_ruby_timezone(argv.pop)
    else
      utc = "-07:00"
    end

    if argv.length == 1
      given_time = argv.first
      current_stamina = 0
    elsif argv.length == 2
      given_time = argv.last
      current_stamina = argv.first.to_i
    else
      reply_on_bad_syntax(m) and return
    end

    t = DateTime.strptime(given_time + utc, "%H:%M%z").to_time
    delta = t - Time.now
    delta = (delta > 0) ? delta : delta + 86400
    stamina = (delta / (60 * minPerStam)).round

    if current_stamina == 0
      r = "By #{t.getlocal(utc).strftime("%I:%M%p")} UTC#{utc}, you will have gained #{stamina} stamina"
    else 
      r = "By #{t.getlocal(utc).strftime("%I:%M%p")} UTC#{utc}, you will have gained #{stamina} stamina, for a total of #{current_stamina + stamina}"
    end
    m.reply r
  end
end

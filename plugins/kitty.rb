class KittyPlugin < PazudoraPluginBase
  def self.aliases
    ["kitty", "kittypull"]
  end

  def self.helpstring
"!pad kitty: Simulates a roll from the Hello Kitty collab machine."
  end

  def respond(m, args)
    test = rand(100)
    if test < 5
      m.reply "You got #1162 Pompompurin!"
    elsif test < 10
      m.reply "You got #1164 Goddess Hello Kitty!"
    elsif test < 25
      m.reply "You got #1154 My Melody."
    elsif test < 40
      m.reply "You got #1156 Bad Badtz-Maru."
    elsif test < 55
      m.reply "You got #1158 Kuromi."
    elsif test < 70
      m.reply "You got #1160 Cinnamoroll."
    elsif test < 85
      m.reply "You got #1150 Hello Kitty."
    else
      m.reply "You got #1152 Kerokerokeroppi."
    end 
  end
end

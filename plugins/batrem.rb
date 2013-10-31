class BatremPlugin < PazudoraPluginBase
  def self.aliases
    ["batREM", "batman", "batroll"]
  end

  def self.helpstring
"!pad batREM: Simulates a roll from the Batman collab machine."
  end

  def respond(m, args)
    test = rand(100)
    if test < 5
      m.reply "You got #679 BAO Batman+Bat Wing, the 5* D/W Balance."
    elsif test < 10
      m.reply "You got #675 BAO Batman+S.Glove, the 5* D/L Physical."
    elsif test < 40
      m.reply "You got #677 BAO Batman+Batarang, the 4* D/D Attacker. Could be worse."
    elsif test < 70
      m.reply "You got #673 BAO Robin, the 4* G Balance. Womp womp."
    else
      m.reply "You got #671 Catwoman, the 4* F Healer/Sucker Bait."
    end 
  end
end

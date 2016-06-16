class TagsPlugin < PazudoraPluginBase
  def self.helpstring
    "!pad tags - Displays information about the !gacha godfest tags associated with Asterbot"
  end

  def self.aliases
    ['tags']
  end

  def respond(m, args)
    r = "Known tags: [R]oman, [J/J2]apanese, [I/I2]ndian, [N]orse, [E/E2]gyptian, [G]reek, [A/A2]ngels, [D]evils, [C]hinese, [3] Kingdoms, [H]eroes, [S]engoku, [M/M2]achine Stars\n"
    r += "Specials: [4]x godfest, e{X]clude padherder, -odin, -caller, -metatron, -sonia, -norn, -kali, -dragonbound, -beast, -star for 1x\n"
    m.reply r
  end
end

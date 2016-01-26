class TagsPlugin < PazudoraPluginBase
  def self.helpstring
    "!pad tags - Displays information about the !gacha godfest tags associated with Asterbot"
  end

  def self.aliases
    ['tags']
  end

  def respond(m, args)
    r = "Use +[tags] to denote godfest; for example !pad roll +J2,G for a japanese 2.0/greek fest.\n"
    r += "Known tags: [R]oman, [J/J2]apanese, [I/I2]ndian, [N]orse, [E/E2]gyptian, [G]reek, [A/A2]ngels, [D]evils, [C]hinese, [3] Kingdoms, [H]eroes, [S]engoku, [M]achines\n"
    m.reply r
  end
end

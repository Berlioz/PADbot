require 'calc'

class CalcPlugin < PazudoraPluginBase
  def self.aliases
    ['calc']
  end

  def self.helpstring
    "!pad calc EXPR: Computes an arbitrary mathematical expression in sanitized ruby. (example: !pad calc 10000 * 0.7 ^ 2)"
  end

  def respond(m, args)
    output = Calc.evaluate(args.gsub(/\^/, "**"))
    if output.respond_to?(:round)
      if output.to_s.include?(".")
        m.reply "#{args} = %.3f" % output
      else
        m.reply "#{args} = #{output}"
      end
    else
      m.reply "Could not interpret #{args} as a mathematical expression"
    end
  end

end

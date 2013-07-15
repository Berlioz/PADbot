require 'calc'

class CalcPlugin < PazudoraPluginBase
  def self.aliases
    ['calc']
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

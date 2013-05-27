class Wihajster::TestUi
  def initialize
    @said = []
  end

  def choose(question, choices)
    case choices.length
    when 0
      nil 
    else
      choice = choices.first
      choice.is_a?(Array) ? choice.first : choice
    end
  end

  def say(say)
    @said << say
  end

  def log(*args)
    *types, message = *args
    say "[#{types.map(&:to_s).join(".")}] #{message}"
  end

  def exception(e, doing=nil)
    say "Got exception #{e.class.name}: #{e}#{doing ? " while #{doing}.": "."}"
    say "  "+e.backtrace.join("\n  ")
  end

  def event(ev)
    say "Event: #{ev.name} #{ev.attributes.inspect}"
  end

  def ask(question)
    ""
  end

  def agree(to)
    false
  end
end

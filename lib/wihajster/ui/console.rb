class Wihajster::Ui::Console
  extend Forwardable
  def_delegators :highline, :agree, :ask, :say

  attr_accessor :highline

  def initialize
    @highline = ::HighLine.new
  end

  def choose(question, choices)
    case choices.length
    when 0
      nil 
    when 1
      choice = choices.first
      choice.is_a?(Array) ? choice.first : choice
    else
      unless $stdin.tty? && $stdout.tty?
        raise ArgumentError, "Cannot make a choice in non interactive mode"
      end

      responses = {}
      choices.to_a.each_with_index do |o, i|
        if o.is_a?(Array)
          k, v = o.first, o.last
        else  
          k, v = i+1, o
        end
        responses[k.to_s] = v
        say "#{k}. #{v}"
      end
      r = ask(question){|q| q.in = responses.keys }

      responses[r]
    end
  rescue Interrupt
    nil
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
end

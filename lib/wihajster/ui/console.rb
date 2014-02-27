require 'forwardable'
require 'highline'

class Wihajster::Ui::Console
  def initialize(s_out = $stdout, s_in = $stdin)
    @in = s_in
    @out = s_out
  end

  def say(msg)
    @out.puts(msg)
  end

  def ask(question, responses=nil)
    while true
      @out.print("#{question} ")
      @out.flush if @out.respond_to? :flush

      result = @in.gets
      break if result.nil?
      result = result.strip
      break if responses.nil? || responses.include?(result)
    end

    result
  end

  def agree(to, default=true)
    options = default ? "(Yes/no)" : "(No/yes)"
    result = ask("#{to} #{options}")

    (result.downcase == "y") || (result.downcase == "yes") || (result == "" && default)
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
      r = ask(question, responses.keys)

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

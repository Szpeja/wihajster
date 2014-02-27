module Wihajster
  module Ui
    class Headless
      def initialize
        @said = []
      end

      def say(say)
        @said << say
      end

      def ask(question)
        nil
      end

      def agree(to, default=false)
        default
      end

      def choose(question, choices)
        case choices.length
        when 0
          nil
        when 1
          choice = choices.first
          choice.is_a?(Array) ? choice.first : choice
        else
          nil # Cannot choose between multiple choices in headless mode.
        end
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
  end
end
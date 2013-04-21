module Wihajster::Console
  class Ui
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

    def log(type, message)
      say "[#{type}] #{message}"
    end
  end
end

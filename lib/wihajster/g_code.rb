module Wihajster
  class GCode
    class Options < Typed::Base
      byte = lambda{|v| !(0..255).include?(v) && "value must be within 0..255 range" }

      has :fan,         :check => byte
      has :heatbed,     :check => byte
      has :temperature, :check => byte
      has :comments,    Boolean

      attributes.each do |name|
        define_method("#{name}?") do
          v = send(name)
          v && (v != 0)
        end
      end
    end

    attr_accessor :name, :options, :paths
    attr_reader :buffer

    def initialize(name="")
      @name = name
      @buffer = []
      @options = Options.new
    end

    def write(line)
      @buffer << line
    end

    def rewrite!
      @buffer = []
    end

    # Writes a command to a buffer.
    def write_command(name, args)
      o = self.class.commands[name]
      c = [ o[:code] ] + o[:accepts].select{|a| args[a] }.map{|a| "#{a}#{args[a]}" }

      write c.join(" ")
    end

    def baner
      write [
        "; #{name}",
        "; Generated on #{Time.now.strftime("%Y-%m-%d %H:%M")} with Wihajster"
      ].join("\n")
    end

    # An ASCII GCode header
    def header
      banner                  if o.comments?
      fan_on(o.fan)           if o.fan?
      heatbed_on(o.heatbed)   if o.heatbed?
      extruder(o.temperature) if o.temperature?
    end

    def body
      paths.map(&:for_gcode).join("\n")
    end

    def footer
      fan_off      if options[:fan]
      heatbed_off  if options[:heatbed]
      extruder_off if options[:temperature]
    end

    module FormatPath
      def for_gcode
        
      end
    end
    Path.send(:include, FormatPath)

    def to_s
      rewrite!

      header
      body
      footer

      buffer.join("\n")
    end

    def inspect
      "#Wihajster::GCode[#{name.inspect}] #{buffer.length} lines."
    end
  end
end

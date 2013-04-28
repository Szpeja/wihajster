module Wihajster
  class GCode
    require 'wihajster/g_code/commands'
    include Commands

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

    def reset!
      @buffer = []
    end

    # Writes a command to a buffer.
    def write_command(formated_command)
      write formated_command
    end

    def baner
      write [
        "; #{name}",
        "; Generated on #{Time.now.strftime("%Y-%m-%d %H:%M")} with Wihajster"
      ].join("\n")
    end

    # An ASCII GCode header
    def header
      banner                      if o.comments?
      c(:fan_on, o.fan)           if o.fan?
      c(:heatbed_on, o.heatbed)   if o.heatbed?
      c(:extruder, o.temperature) if o.temperature?
    end

    def body
      paths.map(&:for_gcode).join("\n")
    end

    def footer
      c(:fan_off)      if options[:fan]
      c(:heatbed_off)  if options[:heatbed]
      c(:extruder_off) if options[:temperature]
    end

    module FormatPath
      def for_gcode
        
      end
    end
    Path.send(:include, FormatPath)

    def to_s
      reset!

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

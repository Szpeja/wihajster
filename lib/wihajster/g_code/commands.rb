require 'erb'

# List of commands that can be sent to RepRap machine.
#
# Prepared based on http://reprap.org/wiki/G-code
#
# Commands currently do not check for required parameters or correctness of their value. 
# Having those checks (especially static ones) could be very usefull - 
# and would also make validatign GCode very simple.
#
# Not all commands are implmented (some of them can be added in separate 
# modules based on printer and/or capabilities).
#
# Commands can also be defined or redefined by user by calling Commands.command method, 
# so it should be trivial to provide UI for modification of commands, and configuration
# files for specific printers.
#
# == Standard Commands
#
# *G*:: Standard GCode command, such as move to a point.
# *M*:: RepRap defined command, such as turn on a cooling fan.
# *T*:: Select tool nnn. In RepRap, tools are extruders
#
# these G-Codes correspond to methods and are named
#
# == Parameters
#
# Parameters are passed as a hash to method defined by a command.
#
# *S*:: Power parameter, such as the voltage to send to a motor
# *P*:: Time  parameter, such as a time in millimetersseconds
# *R*:: Temperature Parameter - used for temperatures in Celcius degrees
#
# *X*:: A X coordinate, usually to move to
# *Y*:: A Y coordinate, usually to move to
# *Z*:: A Z coordinate, usually to move to
# *E*:: Length of extrudate in mm. This is exactly like X, Y and Z, but for the length of filament to extrude. Skeinforge 40 and up interprets this as the absolute length of input filament to consume
#
# *F*:: Format Feedrate in mm per minute. (Speed of print head movement)
#
# == Special commands
#
# *N*:: Line number. Used to Requestt repeat transmission in the case of communications errors.
# *:: Checksum. Used to check for communications errors.
#
module Wihajster::GCode::Commands
  PARAMETERS = {
    S: "Power parameter, such as the voltage to send to a motor",
    P: "Time  parameter, such as a time in millimetersseconds",
    R: "Temperature Parameter - used for temperatures in Celcius degrees",
    
    X: "A X coordinate, usually to move to",
    Y: "A Y coordinate, usually to move to",
    Z: "A Z coordinate, usually to move to",
    E: "Length of extrudate in mm. This is exactly like X, Y and Z, but for the length of filament to extrude.",

    F: "Format Feedrate in mm per minute. (Speed of print head movement)",
  }

  # Generates raw YAML file based on reprap g-code wiki entry.
  def self.generate_yaml
    raw_sections = File.read(__FILE__.gsub('.rb', '.wiki')).
      split(/^==/).
      map{|l| /=*(.+):(.+)====(.+)/m.match(l)}.compact

    sections = raw_sections.map do |r| 
      desc = r[3].strip.gsub(/{\|.+?\|}/m, '').gsub(/\n\s+/m, "\n").strip 
      name = r[2].strip
      method_name = name.gsub(/\(.+\)/, '').strip.gsub(/\W+/,'_').downcase
      code = r[1].strip

      example_matcher = /^(Example:) ([\w .<>-]+?)(#.+)?$/
      if match = example_matcher.match(desc)
        example = match[2]
        desc.sub!(example_matcher, '\3').sub('#', '')
      end

      potential_params = desc.scan(/\s([XYZEFSPR])\d*(?!\d)/).map{|m| m[0].to_sym}.uniq

      {
        code: code, 
        name: name,
        example: example, 
        method_name: method_name, 
        description: desc, 
        accepts: potential_params,
      }
    end

    File.open(__FILE__.gsub('.rb', '.yml'), "w"){|f| f.write sections.to_yaml }
  end

  def self.generate_help
    require 'erb'

    help_template_path = File.join(Wihajster.root, "assets", "g_code.html.erb")
    help_template = File.read(help_template_path)

    commands

    help_table = ERB.new(help_template).result(binding)

    File.open(File.join(Wihajster.root, "doc", "gcode.html"), "w") do |f|
      f.write help_table
    end
  end

  def self.commands
    @commands ||= 
      YAML.load_file(__FILE__.gsub('.rb', '.yml')).
      inject({}){|h, e| h[e[:name]] = OpenStruct.new(e); h }
  end

  def format_command(name, args)
    command = self.class.commands[name]
    arguments = command.accepts.select{|a| args[a] }.map{|a| "#{a}#{args[a]}" } 

    [command.code, arguments].flatten.join(" ")
  end

  def commands
    self.class.commands
  end

  def method_missing(name, *args)
    if respond_to?(name)
      format_command(name, args)
    else
      super
    end
  end 

  def respond_to?(name)
    commands.has_key?(name.to_s) || super
  end
end

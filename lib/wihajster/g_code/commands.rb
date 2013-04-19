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

  def self.generate_yml
    content = File.read(__FILE__.gsub('.rb', '.wiki')).
      split(/^==/).
      map{|l| /=*(.+):(.+)====(.+)/m.match(l)}.compact.
      map do |r| 
        desc = r[3].strip.gsub(/{\|.+?\|}/m, '').gsub(/\n\s+/m, "\n").strip 
        name = r[2].strip
        method_name = name.gsub(/\(.+\)/, '').strip.gsub(/\s+/,'_').downcase
        code = r[1].strip

        {code: code, name: name, method_name: method_name, description: desc, accepts: PARAMETERS.keys }
      end
    File.open(__FILE__.gsub('.rb', '.yml'), "w"){|f| f.write content.to_yaml }
  end

  def self.generate_help

  end

  def self.commands
    @commands ||= 
      YAML.load(__FILE__.gsub('.rb', '.yml')).
      inject({}){|h, e| h[e[:name]] = OpenStruct.new(e); h }
  end

  def format_command(name, args)
    command = self.class.commands[name]
    arguments = command.accepts.select{|a| args[a] }.map{|a| "#{a}#{args[a]}" } 

    [command.code, arguments].flatten.join(" ")
  end

  def method_missing(name, *args)
    if self.class.commands.has_key?(name)
      format_command(name, args)
    else
      super
    end
  end 
end

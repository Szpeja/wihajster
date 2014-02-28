require 'ostruct'

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
module Wihajster::GCode
  class << self
    def parameters
      {
        S: 'Power parameter, such as the voltage to send to a motor',
        P: 'Time  parameter, such as a time in millimetersseconds',
        R: 'Temperature Parameter - used for temperatures in Celcius degrees',

        X: 'A X coordinate, usually to move to',
        Y: 'A Y coordinate, usually to move to',
        Z: 'A Z coordinate, usually to move to',
        E: 'Length of extrudate in mm. This is exactly like X, Y and Z, but for the length of filament to extrude.',

        F: 'Format Feed rate in mm per minute. (Speed of print head movement)',
      }
    end

    # Loads list of commands from YAML reference.
    #
    # Returns hash in format of "Command Name" => Open Struct
    #
    # value has following methods:
    #
    # * code        [String]
    # * name        [String]
    # * example     [String|nil]
    # * method_name [String]
    # * description [String]
    # * accepts     [Array]
    #
    def load_commands 
      YAML.load_file(File.join(__FILE__.gsub(/\.rb$/, ''), 'commands.yml')).
        inject({}){|h, e| h[e[:name]] = OpenStruct.new(e); h }
    end

    def commands
      @commands ||= load_commands
    end
  end

  commands.each do |name, command|
    if command.supported
      define_method(command.method_name) do |options={}|
        fc = format_command(command, options)
        write_command(fc)
      end
    end
  end

  # Formats command into string validating parameters.
  # Unrecognized parameters generate warnings.
  def format_command(c, params={})
    params.select{|k,v| !c.accepts.include?(k) }.each do |k, v|
      Wihajster.ui.log :gcode, c.code, 
        "Unrecognized option #{k} for #{c.code} - #{c.method_name}"
    end

    arguments = Wihajster::GCode.parameters.
      select{|name, desc| params[name]}.
      map{|a, d| "#{a}#{params[a]}" } 

    [c.code, arguments].flatten.join(" ")
  end

  # Writes a gcode to output device.
  # This method should be overridden in class that includes this module.
  def write_command(formated_command)
    Wihajster.ui.log(:gcode, :write, formated_command)
  end
end

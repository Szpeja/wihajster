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
  # Generates raw YAML file based on reprap g-code wiki entry.
  #
  # Wiki file entry is used to bootstrap YAML file,
  # which is ment as a reference for RepRap printer commands.
  def self.generate_yaml
    raw_sections = File.read(__FILE__.gsub('.rb', '.wiki')).
      split(/^==/).
      map{|l| /=*(.+):(.+)====(.+)/m.match(l)}.compact

    sections = raw_sections.map do |r| 
      desc = r[3].strip.gsub(/{\|.+?\|}/m, '').gsub(/\n\s+/m, "\n").strip 
      name = r[2].strip
      method_name = name.gsub(/\(.+\)/, '').strip.gsub(/\W+/,'_').downcase
      code = r[1].strip

      potential_params = desc.scan(/\s([XYZEFSPR])\d*(?!\w)/).map{|m| m[0].to_sym}.uniq.sort

      example_matcher = /^(Example:) ([\w .<>-]+?)(#.+)?$/
      if match = example_matcher.match(desc)
        example = match[2]
        desc.sub!(example_matcher, '\3').sub('#', '')
      end

      {
        code: code, 
        name: name,
        example: example, 
        method_name: method_name, 
        description: desc, 
        accepts: potential_params,
        supported: true,
      }
    end

    File.open(__FILE__.gsub('.rb', '.yml'), "w"){|f| f.write sections.to_yaml }
  end

  # Generates help table based on reference YAML reference file.
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
end

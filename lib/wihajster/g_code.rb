require 'ostruct'
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
module Wihajster::GCode
  Wihajster.load_libraries "g_code"

  # **GCodeCommand** has following methods:
  #
  # * code        [String]
  # * name        [String]
  # * example     [String|nil]
  # * method_name [String]
  # * description [String]
  # * accepts     [Array]
  class GCodeCommand < OpenStruct
    def comment
      line_width = 100
      h = "*#{code}* **#{name}**"
      fd = description.gsub(/^#/, "*").gsub(/(.{1,#{line_width}})(\s|$)/, "\\1\n")
      if accepts && accepts.length > 0
        args = "Arg | Description\n--- | ---\n"+accepts.map{|a| "%-3s | %s" % [a, Wihajster::GCode.parameters[a]] }.join("\n")
        yard = "@param args [Hash] arguments for GCode can be one of #{accepts}"
      end
      [h, fd.strip, args, yard].compact.join("\n\n").gsub(/^/, "  # ").strip
    end
  end

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

    # Generates raw YAML file based on reprap g-code wiki entry.
    #
    # Wiki file entry is used to bootstrap YAML file,
    # which is ment as a reference for RepRap printer commands.
    def generate_yaml
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
            accepts: potential_params,
            supported: true,
            method_name: method_name,
            description: desc,
        }
      end

      File.open(__FILE__.gsub('.rb', '.yml'), "w"){|f| f.write sections.to_yaml }
    end

    # Loads list of commands from YAML reference.
    #
    # Returns hash in format of "Command Name" => GCodeCommand
    def load_commands
      commands_yaml = File.join(__FILE__.gsub(/\.rb$/, ''), 'commands.yml')
      YAML.load_file(commands_yaml).inject({}) do |h, e|
        h[e[:name]] = GCodeCommand.new(e); h
      end
    end

    # Generates list of commands from YAML reference.
    def generate_commands
      commands_file_path = File.join(Wihajster.root, "lib", "wihajster", "g_code", "commands.rb")
      File.open(commands_file_path, "w") do |f|
        f.puts "module Wihajster::GCode::Commands"
        commands.each_pair do |name, command|
          f.puts <<-RUBY.gsub /^\s{10}/, ""
            #{command.comment}
            def #{command.method_name}(args={})
              fc = Wihajster::GCode.format_command("#{command.name}", arguments)
              write_command(fc)
            end

          RUBY
        end
        f.puts "end"
      end
    end

    # Generates help table based on reference YAML reference file.
    def generate_help
      help_template_path = File.join(Wihajster.root, "assets", "g_code.html.erb")
      help_template = File.read(help_template_path)

      commands

      help_table = ERB.new(help_template).result(binding)

      File.open(File.join(Wihajster.root, "doc", "gcode.html"), "w") do |f|
        f.write help_table
      end
    end

    def commands
      @commands ||= load_commands
    end

    # Formats command into string validating parameters.
    # Unrecognized parameters generate warnings.
    def format_command(command_name, params={})
      c = Wihajster::GCode.commands[command_name]

      params.select{|k,v| !c.accepts.include?(k) }.each do |k, v|
        Wihajster.ui.log :gcode, c.code, "Unrecognized option #{k} for #{c.code} - #{c.method_name}"
      end

      arguments = Wihajster::GCode.parameters.
        select{|name, desc| params[name]}.
        map{|a, d| "#{a}#{params[a]}" }

      [c.code, arguments].flatten.join(" ")
    end
  end
end

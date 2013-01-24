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

    # List of commands that can be sent to RepRap machine.
    #
    # Prepared based on http://reprap.org/wiki/G-code
    #
    # Commands currently do not check for required parameters or correctness of their value. 
    # Having those checks (especially static ones) could be very usefull - 
    # and would also make validatign GCode very simply.
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
    # Parameters are passed as a hash to method defined bu a command.
    #
    # *S*:: Power parameter, such as the voltage to send to a motor
    # *P*:: Time  parameter, such as a time in millimetersseconds
    # *R*:: Temperature Parameter - used for temperatures in Celcius degrees
    #
    # *X*:: A X coordinate, usually to move to
    # *Y*:: A Y coordinate, usually to move to
    # *Z*:: A Z coordinate, usually to move to
    # *E*:: Length of extrudate in mm. This is exactly like X, Y and Z, but for the length of filament to extrude. Skeinforge 40 and up interprets this as the absolute length of input filament to consume, rather than the length of the extruded output.
    #
    # *F*:: Format Feedrate in mm per minute. (Speed of print head movement)
    #
    # == Special commands
    #
    # *N*:: Line number. Used to Requestt repeat transmission in the case of communications errors.
    # *:: Checksum. Used to check for communications errors. 
    #
    module RepRapCommands
      BUFFERED = [:move_fast, :move, :move_home]
      OFF = 0
      ON = 255

      # List of all reprap commands.
      #
      # Format:
      #
      #   {
      #     :command_name => {
      #       :code => 'GCode',
      #       :accepts => [:X, :Y, :Z, ... ],
      #       :buffered => [true/false]
      #     }
      #   }
      def self.commands
        @commands ||= {}
      end

      # Defines a command given name, associated GCODE and possible arguments
      def self.command(name, code, *accepts)
        commands[name] = {
          :code => code,
          :accepts => accepts.flatten,
          :buffered => BUFFERED.include?(name)
        }

        define_method(name) do |arguments|
          write_command(name, arguments)
        end
      end

      ##
      # :call-seq:
      #   move_fast
      #   move_fast X:0, Y:0, Z:0, E:0
      #   move_fast X: 12 # units(mm or inches)
      #
      # Example: G0 X12
      #
      # In this case move rapidly to X = 12 mm. In fact, the RepRap firmware uses exactly the same 
      # code for rapid as it uses for controlled moves (see G1 below), as - for the RepRap machine -
      # this is just as efficient as not doing so. 
      # The distinction comes from some old machine tools that used to move faster if the axes were 
      # not driven in a straight line. For them G0 allowed any movement in space to get to the 
      # destination as fast as possible.
      command :move_fast, 'G0', [:X, :Y, :Z, :E, :F]
      
      ##
      # :call-seq:
      #   move 
      #   move X:90 # move 90 units(mm/inches)
      #   move E:10 # extrude 10 units(mm/inches) of filament(input, NOT extruded filament)
      #   move F:1000 # set feedrate to 1000 unit(mm/inch)/minute
      #   move X:90.6, Y:13.8, E:22.4
      #
      # Example: G1 X90.6 Y13.8 E22.4
      #
      # Go in a straight line from the current (X, Y) point to the point (90.6, 13.8), extruding 
      # material as the move happens from the current extruded length to a length of 22.4 mm.
      # RepRap does subtle things with feedrates. Thus:
      #
      #   G1 F1500
      #   G1 X90.6 Y13.8 E22.4
      #
      # Will set a feedrate of 1500 mm/minute, then do the move described above at that feedrate. 
      # But
      #
      #   G1 F1500
      #   G1 X90.6 Y13.8 E22.4 F3000
      #
      # Will set a feedrate of 1500 mm/minute, then do the move described above accelerating to a 
      # feedrate of 3000 mm/minute as it does so. 
      # The extrusion will accelerate along with the X, Y movement so everything stays synchronized.
      #
      # RepRap thus treats feedrate as simply another variable (like X, Y, Z, and E) to be linearly 
      # interpolated. This gives complete control over accelerations and decelerations in a way that 
      # ensures that everything moves together and the right volume of material is extruded at all points. 
      #
      # Note: not every firmware implements this, e.g. the current Marlin will use the new feedrate 
      # from the beginning of the move and not change it.
      command :move, 'G1', [:X, :Y, :Z, :E, :F]
     
      ##
      # :call-seq:
      #   move_home
      #   move_home X:0, Y:0, Z:0
      #
      # Example: G28
      #
      # This causes the RepRap machine to move back to its X, Y and Z zero endstops, 
      # a process known as "homing". It does so accelerating, so as to get there fast. 
      # But when it arrives it backs off by 1 mm in each direction slowly, then moves back slowly to the stop. 
      # This ensures more accurate positioning.
      #
      # If you add coordinates, then just the axes with coordinates specified will be zeroed. Thus 
      #
      #   G28 X0 Y72.3
      #
      # will zero the X and Y axes, but not Z. The actual coordinate values are ignored. 
      command :move_home, 'G28', [:X, :Y, :Z]

      ##
      # :call-seq:
      #   dwell 200 # miliseconds
      #
      # Example: G4 P200
      #
      # In this case sit still doing nothing for 200 milliseconds. During delays the state of the machine 
      # (for example the temperatures of its extruders) will still be preserved and controlled.
      command :dwell, 'G4', :P

      ##
      # Head Offset
      #
      # Used for printers with multiple heads. Still in discussion. Check firmware.
      #
      # :call-seq:
      #   head_offset P:3, X:17.8, Y:19.3, Z:0.0, R:140, S: 205
      #
      # Example: G10 P3 X17.8 Y-19.3 Z0.0 R140 S205
      #
      # This sets the offset for extrude head 3 (from the P3) to the X and Y values specified. 
      # You can put a non-zero Z value in as well, but this is usually a bad idea unless the heads are 
      # loaded and unloaded by some sort of head changer. When all the heads are in the machine at once 
      # they should all be set to the same Z height.
      #
      # Remember that any parameter that you don't specify will automatically be set to the last value 
      # for that parameter. That usually means that you want explicitly to set Z0.0.
      #
      # The R value is the standby temperature in oC that will be used for the tool, and the S value is 
      # its operating temperature. If you don't want the head to be at a different temperature when not 
      # in use, set both values the same. See the T code ( #select_tool ) below.
      command :head_offset, 'G10', [:P, :X, :Y, :Z, :R, :P]

      ##
      # G20: Set Units to Inches
      #
      # Example: G20
      #
      # Units from now on are in inches.
      command :set_unit_to_inches, 'G20'

      ##
      # G21: Set Units to Millimeters
      #
      # Example: G21
      #
      # Units from now on are in millimeters. (This is the RepRap default.)
      command :set_unit_to_mm, 'G21'

      ##
      # G90: Set to Absolute Positioning
      #
      # Example: G90
      #
      # All coordinates from now on are absolute relative to the origin of the machine. (This is the RepRap default.) 
      command :set_absolute_positioning, 'G90'

      ##
      # G91: Set to Relative Positioning
      #
      # Example: G91
      #
      # All coordinates from now on are relative to the last position. 
      command :set_relative_positioning, 'G91'

      ##
      # G92: Set Position
      #
      # Example: G92 X10 E90
      #
      # Allows programming of absolute zero point, by reseting the current position to the values specified. 
      # This would set the machine's X coordinate to 10, and the extrude coordinate to 90. 
      #
      # *No physical motion will occur!*
      #
      # A G92 without coordinates will reset all axes to zero. 
      command :force_position, 'G92', :X, :Y, :Z, :E

      ##
      # M0: Stop
      #
      # Example: M0
      #
      # The RepRap machine finishes any moves left in its buffer, then shuts down. 
      # All motors and heaters are turned off. 
      # It can be started again by pressing the reset button on the master microcontroller. 
      #
      # See also M1 ( #sleep ), M112. 
      command :stop, 'M0'

      ##
      # M1: Sleep
      #
      # Example: M1
      #
      # The RepRap machine finishes any moves left in its buffer, then shuts down. 
      # All motors and heaters are turned off. 
      # It can still be sent G and M codes, the first of which will wake it up again. 
      #
      # See also M0( #stop ), M112.
      command :sleep, 'M1'

      ##
      # M17: Enable/Power all stepper motors
      #
      # Example: M17 
      command :start_engines, 'M17'

      ##
      # M18: Disable all stepper motors
      #
      # Example: M18
      #
      # Disables stepper motors and allows axis to move 'freely.' 
      command :stop_engines, 'M18'

      ##
      # M40: Eject
      #
      # If your RepRap machine can eject the parts it has built off the bed, this command executes the eject cycle. 
      # This usually involves cooling the bed and then performing a sequence of movements that 
      # remove the printed parts from it. The X, Y and Z position of the machine at the end of 
      # this cycle are undefined (though they can be found out using the M114 command, q.v.).
      #
      # See also M240 and M241 below.
      command :eject, 'M40'

      ##
      # M41: Loop
      #
      # Example: M41
      #
      # If the RepRap machine was building a file from its own memory such as a local SD card 
      # (as opposed to a file being transmitted to it from a host computer) this goes back to the 
      # beginning of the file and runs it again. So, for example, if your RepRap is capable of 
      # ejecting parts from its build bed then you can set it printing in a loop and it will run and run. 
      # Use with caution - the only things that will stop it are:
      #
      # * When you press the reset button,
      # * When the build material runs out (if your RepRap is set up to detect this), and
      # * When there's an error (such as a heater failure). 
      command :loop_printer, 'M41'

      ##
      # M42 in Marlin/Sprinter
      #
      # Example: M42 P7 S255
      #
      # M42 switches a general purpose I/O pin. 
      command :general_purpose_io_switch, 'M42', :P, :S

      ##
      # M42: Stop on material exhausted in ??
      #
      # Example: M42
      #
      # If your RepRap can detect when its material runs out, this decides the behaviour when that happens. 
      # The X and Y axes are zeroed (but not Z), and then the machine shuts all motors and heaters off. 
      # You have to press reset to reactivate the machine. 
      # In other words, it parks itself and then executes an M0 command (q.v.). 
      command :stop_on_manterial_exhausted, 'M42'

      ##
      # M43: Stand by on material exhausted
      #
      # Example: M43
      #
      # If your RepRap can detect when its material runs out, this decides the behaviour when that happens. 
      # The X and Y axes are zeroed (but not Z), and then the machine shuts all motors and heaters off except 
      # the heated bed, the temperature of which is maintained. 
      # The machine will still respond to G and M code commands in this state
      command :stand_by_on_material_exhausted, 'M43'

      ##
      # M80: ATX Power On
      #
      # Example: M80
      #
      # Turns on the ATX power supply from standby mode to fully operational mode. 
      # No-op on electronics without standby mode.
      # Note: some firmwares, like Teacup, handle power on/off automatically, so this is redundant there.
      command :atx_power_on, 'M80'

      ##
      # M81: ATX Power Off
      #
      # Example: M81
      #
      # Turns off the ATX power supply. Counterpart to M80.
      command :atx_power_off, 'M81'
      
      ##
      # M82: set extruder to absolute mode
      #
      # Example: M82
      #
      # makes the extruder interpret extrusion as absolute positions.
      #
      # This is the default in repetier.
      command :set_extruder_absolute_mode, 'M82'
      
      ##
      # M83: set extruder to relative mode
      #
      # Example: M83
      #
      # makes the extruder interpret extrusion values as relative positions. 
      command :set_extruder_relative_mode, 'M83'

      ##
      # M92: Set axis_steps_per_unit
      #
      # Example: M92 X<newsteps> Sprinter and Marlin
      #
      # Allows programming of steps per unit of axis till the electronics are reset for the specified axis. 
      # Very useful for calibration. 
      command :set_steps_per_unit, 'M92', :X, :Y, :Z

      ##
      # M104: Set Extruder Temperature
      #
      # Example: M104 S190
      #
      # Set the temperature of the current extruder to 190oC and return control to the host immediately 
      # (i.e. before that temperature has been reached by the extruder). 
      # See also M109( #set_extruder_temperature_and_wait ).
      #
      # This is deprecated because temperatures should be set using the G10 and T commands (q.v.). 
      # See also #head_offset
      command :set_extruder_temperature, 'M104', :S

      ##
      # M105: Get Extruder Temperature
      #
      # Example: M105
      #
      # Request the temperature of the current extruder and the build base in degrees Celsius. 
      # The temperatures are returned to the host computer. 
      # For example, the line sent to the host in response to this command looks like
      #
      # ok T:201 B:117 
      command :get_extruder_temperature, 'M105'

      ##
      # M106: Fan On
      #
      # Example: M106 S127
      #
      # Turn on the cooling fan at half speed. Mandatory parameter 'S' declares the PWM value (0-255). 
      # M106 S0 turns the fan off. 
      command :fan, 'M106', :S
      alias_method :fan_on, :fan

      ##
      # M107: Fan Off
      #
      # Deprecated. Use M106 S0 ( #fan OFF ) instead. 
      command :fan_off, 'M107'

      ##
      # M109: Set Extruder Temperature and Wait
      #
      # Deprecated. Use M104, followed by an M116, instead.
      #
      # Another way to do this is to use G10.
      command :set_extruder_temperature_sync, 'M109', :S

      ##
      #  M111: Set Debug Level
      #
      #  Example: M111 S6
      #
      #  Set the level of debugging information transmitted back to the host to level 6. 
      #  The level is the OR of three bits:
      #
      #    #define DEBUG_ECHO (1<<0)
      #    #define DEBUG_INFO (1<<1)
      #    #define DEBUG_ERRORS (1<<2)
      #
      #  Thus 6 means send information and errors, but don't echo commands. (This is the RepRap default.) 
      command :set_debug_level, 'M111', :S

      ##
      # M112: Emergency Stop
      #
      # Example: M112
      #
      # Any moves in progress are immediately terminated, then RepRap shuts down. 
      # All motors and heaters are turned off. 
      # It can be started again by pressing the reset button on the master microcontroller. 
      #
      # See also M0 and M1 ( #stop and #sleep ). 
      command :emergency_stop, 'M112'
      alias_method :panic, :emergency_stop

      ##
      # M113: Set Extruder PWM
      #
      # :call-seq:
      #   set_extruder_pwm       # makes reprap use on-board potentiometr for PWM
      #   set_extruder_pwm S:0.7 # Sets PWM to 70%
      #   set_extruder_pwm S:0   # Turns off extruder
      #
      # Example: M113
      #
      # Set the PWM for the currently-selected extruder. 
      # On its own this command sets RepRap to use the on-board potentiometer on the extruder 
      # controller board to set the PWM for the currently-selected extruder's stepper power. 
      #
      # With an S field:
      #
      #   M113 S0.7
      #
      # it causes the PWM to be set to the S value (70% in this instance). 
      #
      # M113 S0 turns the extruder off, until an M113 command other than M113 S0 is sent. 
      command :set_extruder_pwm, 'M113', :S

      ##
      # M114: Get Current Position
      #
      # Example: M114
      #
      # This causes the RepRap machine to report its current X, Y, Z and E coordinates to the host.
      #
      # For example, the machine returns a string such as:
      #
      # ok C: X:0.00 Y:0.00 Z:0.00 E:0.00 
      command :get_current_position, 'M114'

      ##
      # M116: Wait
      #
      # Example: M116
      #
      # Wait for all temperatures and other slowly-changing variables to arrive at their set values. 
      # See also M109 ( #extruder_temperature_and_wait )
      command :wait_for_heaters, 'M116'

      ##
      # M117: Get Zero Position
      #
      # Example: M117
      #
      # This causes the RepRap machine to report the X, Y, Z and E coordinates in steps not mm to the 
      # host that it found when it last hit the zero stops for those axes. 
      #
      # That is to say, when you zero X, the x coordinate of the machine when it hits the X endstop is recorded. 
      #
      # This value should be 0, of course. But if the machine has drifted 
      # (for example by dropping steps) then it won't be. 
      # This command allows you to measure and to diagnose such problems. 
      # (E is included for completeness. It doesn't normally have an endstop.) 
      command :get_zero_position, 'M117'

      ##
      # M128: Extruder Pressure PWM
      #
      # Example: M128 S255
      #
      # PWM value to control internal extruder pressure. S255 is full pressure. 
      command :set_extruder_pressure_pwm, 'M128', :S

      ##
      # M129: Extruder pressure off
      #
      # :call-seq:
      #   extruder_pressure_pwm_off 100 #ms
      #
      # Example: M129 P100
      #
      # In addition to setting Extruder pressure to 0, you can turn the pressure off entirely. P400 will wait 100ms to do so.
      command :extruder_pressure_pwm_off, 'M129', :P

      
    end
  end
end

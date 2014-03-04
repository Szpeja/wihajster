module Wihajster::GCode::Commands
  # *G0* **Rapid move**
  # 
  # In this case move rapidly to X = 12 mm.  In fact, the RepRap firmware uses exactly the same code for
  # rapid as it uses for controlled moves (see G1 below), as - for the RepRap machine - this is just as
  # efficient as not doing so.  (The distinction comes from some old machine tools that used to move
  # faster if the axes were not driven in a straight line.  For them G0 allowed any movement in space to
  # get to the destination as fast as possible.)
  # 
  # Arg | Description
  # --- | ---
  # E   | Length of extrudate in mm. This is exactly like X, Y and Z, but for the length of filament to extrude.
  # F   | Format Feed rate in mm per minute. (Speed of print head movement)
  # X   | A X coordinate, usually to move to
  # Y   | A Y coordinate, usually to move to
  # Z   | A Z coordinate, usually to move to
  # 
  # @param args [Hash] arguments for GCode can be one of [:E, :F, :X, :Y, :Z]
  def rapid_move(args={})
    fc = Wihajster::GCode.format_command("Rapid move", arguments)
    write_command(fc)
  end

  # *G1* **Controlled move**
  # 
  # Go in a straight line from the current (X, Y) point to the point (90.6, 13.8), extruding material as
  # the move happens from the current extruded length to a length of 22.4 mm.
  # RepRap does subtle things with feedrates.  Thus:
  # <pre>
  # G1 F1500
  # G1 X90.6 Y13.8 E22.4
  # </pre>  
  # Will set a feedrate of 1500 mm/minute, then do the move described above at that feedrate.  But
  # <pre>
  # G1 F1500
  # G1 X90.6 Y13.8 E22.4 F3000
  # </pre>
  # Will set a feedrate of 1500 mm/minute, then do the move described above accelerating to a feedrate
  # of 3000 mm/minute as it does so.  The extrusion will accelerate along with the X, Y movement so
  # everything stays synchronized.
  # RepRap thus treats feedrate as simply another variable (like X, Y, Z, and E) to be linearly
  # interpolated. This gives complete control over accelerations and decelerations in a way that ensures
  # that everything moves together and the right volume of material is extruded at all points.
  # ''Note: not every firmware implements this, e.g. the current [[Marlin]] will use the new feedrate
  # from the beginning of the move and not change it.''
  # The first example shows how to get a constant-speed movement.  The second how to accelerate or
  # decelerate.  Thus
  # <pre>
  # G1 F1500
  # G1 X90.6 Y13.8 E22.4 F3000
  # G1 X80 Y20 E36 F1500
  # </pre>
  # Will do the first movement accelerating as before, and the second decelerating from 3000 mm/minute
  # back to 1500 mm/minute.
  # To reverse the extruder by a given amount (for example to reduce its internal pressure while it does
  # an in-air movement so that it doesn't dribble) simply use G1 to send an E value that is less than
  # the currently extruded length.
  # 
  # Arg | Description
  # --- | ---
  # E   | Length of extrudate in mm. This is exactly like X, Y and Z, but for the length of filament to extrude.
  # F   | Format Feed rate in mm per minute. (Speed of print head movement)
  # X   | A X coordinate, usually to move to
  # Y   | A Y coordinate, usually to move to
  # Z   | A Z coordinate, usually to move to
  # 
  # @param args [Hash] arguments for GCode can be one of [:E, :F, :X, :Y, :Z]
  def move(args={})
    fc = Wihajster::GCode.format_command("Controlled move", arguments)
    write_command(fc)
  end

  # *G28* **Move to Origin**
  # 
  # This causes the RepRap machine to move back to its X, Y and Z zero endstops, a process known as
  # "homing".  It does so accelerating, so as to get there fast.  But when it arrives it backs off by 1
  # mm in each direction slowly, then moves back slowly to the stop.  This ensures more accurate
  # positioning.  
  # If you add coordinates, then just the axes with coordinates specified will be zeroed.  Thus 
  # G28 X0 Y72.3
  # will zero the X and Y axes, but not Z.  The actual coordinate values are ignored.
  # 
  # Arg | Description
  # --- | ---
  # X   | A X coordinate, usually to move to
  # Y   | A Y coordinate, usually to move to
  # Z   | A Z coordinate, usually to move to
  # 
  # @param args [Hash] arguments for GCode can be one of [:X, :Y, :Z]
  def move_to_origin(args={})
    fc = Wihajster::GCode.format_command("Move to Origin", arguments)
    write_command(fc)
  end

  # *G29* **Detailed Z-Probe**
  # 
  # probes the bed at 3 points.
  def detailed_z_probe(args={})
    fc = Wihajster::GCode.format_command("Detailed Z-Probe", arguments)
    write_command(fc)
  end

  # *G30* **Single Z Probe**
  # 
  # probes bed at current XY location.
  def single_z_probe(args={})
    fc = Wihajster::GCode.format_command("Single Z Probe", arguments)
    write_command(fc)
  end

  # *G31* **Report Current Probe status**
  # 
  # reports whether Z probe is triggered.
  # 
  # Arg | Description
  # --- | ---
  # Z   | A Z coordinate, usually to move to
  # 
  # @param args [Hash] arguments for GCode can be one of [:Z]
  def report_current_probe_status(args={})
    fc = Wihajster::GCode.format_command("Report Current Probe status", arguments)
    write_command(fc)
  end

  # *G32* **Probe Z and calibrate with FPU**
  # 
  # probes the bed at 3 points and updates transformation matrix for bed leveling compensation.
  def probe_z_and_calibrate_with_fpu(args={})
    fc = Wihajster::GCode.format_command("Probe Z and calibrate with FPU", arguments)
    write_command(fc)
  end

  # *G4* **Dwell**
  # 
  # In this case sit still doing nothing for 200 milliseconds.  During delays the state of the machine
  # (for example the temperatures of its extruders) will still be preserved and controlled.
  # 
  # Arg | Description
  # --- | ---
  # P   | Time  parameter, such as a time in millimetersseconds
  # 
  # @param args [Hash] arguments for GCode can be one of [:P]
  def dwell(args={})
    fc = Wihajster::GCode.format_command("Dwell", arguments)
    write_command(fc)
  end

  # *G10* **Head Offset**
  # 
  # This sets the offset for extrude head 3 (from the P3) to the X and Y values specified.  You can put
  # a non-zero Z value in as well, but this is usually a bad idea unless the heads are loaded and
  # unloaded by some sort of head changer.  When all the heads are in the machine at once they should
  # all be set to the same Z height.
  # Remember that any parameter that you don't specify will automatically be set to the last value for
  # that parameter.  That usually means that you want explicitly to set Z0.0.  
  # The R value is the standby temperature in <sup>o</sup>C that will be used for the tool, and the S
  # value is its operating temperature.  If you don't want the head to be at a different temperature
  # when not in use, set both values the same.  See the T code (select tool) below.
  # The [http://www.nist.gov/customcf/get_pdf.cfm?pub_id=823374 NIST G-code standard] mentions an
  # additional L parameter, which is ignored.
  # This command is [[Talk:G-code#M104 .26 M109 Deprecation, G10 Introduction | subject to discussion]].
  # 
  # Arg | Description
  # --- | ---
  # P   | Time  parameter, such as a time in millimetersseconds
  # R   | Temperature Parameter - used for temperatures in Celcius degrees
  # S   | Power parameter, such as the voltage to send to a motor
  # X   | A X coordinate, usually to move to
  # Y   | A Y coordinate, usually to move to
  # Z   | A Z coordinate, usually to move to
  # 
  # @param args [Hash] arguments for GCode can be one of [:P, :R, :S, :X, :Y, :Z]
  def head_offset(args={})
    fc = Wihajster::GCode.format_command("Head Offset", arguments)
    write_command(fc)
  end

  # *G20* **Set Units to Inches**
  # 
  # Units from now on are in inches.
  def set_units_to_inches(args={})
    fc = Wihajster::GCode.format_command("Set Units to Inches", arguments)
    write_command(fc)
  end

  # *G21* **Set Units to Millimeters**
  # 
  # Units from now on are in millimeters.  (This is the RepRap default.)
  def set_units_to_millimeters(args={})
    fc = Wihajster::GCode.format_command("Set Units to Millimeters", arguments)
    write_command(fc)
  end

  # *G90* **Set to Absolute Positioning**
  # 
  # All coordinates from now on are absolute relative to the origin of the machine.  (This is the RepRap
  # default.)
  def set_to_absolute_positioning(args={})
    fc = Wihajster::GCode.format_command("Set to Absolute Positioning", arguments)
    write_command(fc)
  end

  # *G91* **Set to Relative Positioning**
  # 
  # All coordinates from now on are relative to the last position.
  def set_to_relative_positioning(args={})
    fc = Wihajster::GCode.format_command("Set to Relative Positioning", arguments)
    write_command(fc)
  end

  # *G92* **Set Position**
  # 
  # Allows programming of absolute zero point, by reseting the current position to the values specified.
  #  This would set the machine's X coordinate to 10, and the extrude coordinate to 90. No physical
  # motion will occur.
  # A G92 without coordinates will reset all axes to zero.
  # 
  # Arg | Description
  # --- | ---
  # E   | Length of extrudate in mm. This is exactly like X, Y and Z, but for the length of filament to extrude.
  # X   | A X coordinate, usually to move to
  # 
  # @param args [Hash] arguments for GCode can be one of [:E, :X]
  def set_position(args={})
    fc = Wihajster::GCode.format_command("Set Position", arguments)
    write_command(fc)
  end

  # *M0* **Stop**
  # 
  # The RepRap machine finishes any moves left in its buffer, then shuts down.  All motors and heaters
  # are turned off.  It can be started again by pressing the reset button on the master microcontroller.
  #  See also M1, M112.
  def stop(args={})
    fc = Wihajster::GCode.format_command("Stop", arguments)
    write_command(fc)
  end

  # *M1* **Sleep**
  # 
  # The RepRap machine finishes any moves left in its buffer, then shuts down.  All motors and heaters
  # are turned off.  It can still be sent G and M codes, the first of which will wake it up again.  See
  # also M0, M112.
  def sleep(args={})
    fc = Wihajster::GCode.format_command("Sleep", arguments)
    write_command(fc)
  end

  # *M3* **Spindle On, Clockwise  (CNC specific)**
  # 
  # The spindle is turned on with a speed of 4000 RPM.
  # 
  # Arg | Description
  # --- | ---
  # S   | Power parameter, such as the voltage to send to a motor
  # 
  # @param args [Hash] arguments for GCode can be one of [:S]
  def spindle_on_clockwise(args={})
    fc = Wihajster::GCode.format_command("Spindle On, Clockwise  (CNC specific)", arguments)
    write_command(fc)
  end

  # *M4* **Spindle On, Counter-Clockwise (CNC specific)**
  # 
  # The spindle is turned on with a speed of 4000 RPM.
  # 
  # Arg | Description
  # --- | ---
  # S   | Power parameter, such as the voltage to send to a motor
  # 
  # @param args [Hash] arguments for GCode can be one of [:S]
  def spindle_on_counter_clockwise(args={})
    fc = Wihajster::GCode.format_command("Spindle On, Counter-Clockwise (CNC specific)", arguments)
    write_command(fc)
  end

  # *M5* **Spindle Off (CNC specific)**
  # 
  # The spindle is turned off.
  def spindle_off(args={})
    fc = Wihajster::GCode.format_command("Spindle Off (CNC specific)", arguments)
    write_command(fc)
  end

  # *M7* **Mist Coolant On (CNC specific)**
  # 
  # Mist coolant is turned on (if available)
  def mist_coolant_on(args={})
    fc = Wihajster::GCode.format_command("Mist Coolant On (CNC specific)", arguments)
    write_command(fc)
  end

  # *M8* **Flood Coolant On (CNC specific)**
  # 
  # Flood coolant is turned on (if available)
  def flood_coolant_on(args={})
    fc = Wihajster::GCode.format_command("Flood Coolant On (CNC specific)", arguments)
    write_command(fc)
  end

  # *M9* **Coolant Off (CNC specific)**
  # 
  # All coolant systems are turned off.
  def coolant_off(args={})
    fc = Wihajster::GCode.format_command("Coolant Off (CNC specific)", arguments)
    write_command(fc)
  end

  # *M10* **Vacuum On (CNC specific)**
  # 
  # Dust collection vacuum system turned on.
  def vacuum_on(args={})
    fc = Wihajster::GCode.format_command("Vacuum On (CNC specific)", arguments)
    write_command(fc)
  end

  # *M11* **Vacuum Off (CNC specific)**
  # 
  # Dust collection vacuum system turned off.
  def vacuum_off(args={})
    fc = Wihajster::GCode.format_command("Vacuum Off (CNC specific)", arguments)
    write_command(fc)
  end

  # *M17* **Enable/Power all stepper motors**
  #
  def enable_power_all_stepper_motors(args={})
    fc = Wihajster::GCode.format_command("Enable/Power all stepper motors", arguments)
    write_command(fc)
  end

  # *M18* **Disable all stepper motors**
  # 
  # Disables stepper motors and allows axis to move 'freely.'
  # - Is this not the same as [[#M84:_Stop_idle_hold|M84]]? --  [[User:MrAlvin|MrAlvin]] 05:53, 20
  # September 2012 (UTC)
  def disable_all_stepper_motors(args={})
    fc = Wihajster::GCode.format_command("Disable all stepper motors", arguments)
    write_command(fc)
  end

  # *M20* **List SD card**
  # 
  # All files in the root folder of the SD card are listed to the serial port.  This results in a line
  # like:
  # ok Files: {SQUARE.G,SQCOM.G,}
  # The trailing comma is optional.  Note that file names are returned in upper case, but - when sent to
  # the M23 command (below) they must be in lower case.  This seems to be a function of the SD software.
  #  Go figure...
  def list_sd_card(args={})
    fc = Wihajster::GCode.format_command("List SD card", arguments)
    write_command(fc)
  end

  # *M21* **Initialize SD card**
  # 
  # The SD card is initialized. If an SD card is loaded when the machine is switched on, this will
  # happen by default. SD card must be initialized for the other SD functions to work.
  def initialize_sd_card(args={})
    fc = Wihajster::GCode.format_command("Initialize SD card", arguments)
    write_command(fc)
  end

  # *M22* **Release SD card**
  # 
  # SD card is released and can be physically removed.
  def release_sd_card(args={})
    fc = Wihajster::GCode.format_command("Release SD card", arguments)
    write_command(fc)
  end

  # *M23* **Select SD file**
  # 
  # The file specified as filename.gco (8.3 naming convention is supported) is selected ready for
  # printing.
  def select_sd_file(args={})
    fc = Wihajster::GCode.format_command("Select SD file", arguments)
    write_command(fc)
  end

  # *M24* **Start/resume SD print**
  # 
  # The machine prints from the file selected with the M23 command.
  def start_resume_sd_print(args={})
    fc = Wihajster::GCode.format_command("Start/resume SD print", arguments)
    write_command(fc)
  end

  # *M25* **Pause SD print**
  # 
  # The machine pause printing at the current position within the file selected with the M23 command.
  def pause_sd_print(args={})
    fc = Wihajster::GCode.format_command("Pause SD print", arguments)
    write_command(fc)
  end

  # *M26* **Set SD position**
  # 
  # Set SD position in bytes (M26 S12345).
  # 
  # Arg | Description
  # --- | ---
  # S   | Power parameter, such as the voltage to send to a motor
  # 
  # @param args [Hash] arguments for GCode can be one of [:S]
  def set_sd_position(args={})
    fc = Wihajster::GCode.format_command("Set SD position", arguments)
    write_command(fc)
  end

  # *M27* **Report SD print status**
  # 
  # Report SD print status.
  def report_sd_print_status(args={})
    fc = Wihajster::GCode.format_command("Report SD print status", arguments)
    write_command(fc)
  end

  # *M28* **Begin write to SD card**
  # 
  # File specified by filename.gco is created (or overwritten if it exists) on the SD card and all
  # subsequent commands sent to the machine are written to that file.
  def begin_write_to_sd_card(args={})
    fc = Wihajster::GCode.format_command("Begin write to SD card", arguments)
    write_command(fc)
  end

  # *M29* **Stop writing to SD card**
  # 
  # File opened by M28 command is closed, and all subsequent commands sent to the machine are executed
  # as normal.
  def stop_writing_to_sd_card(args={})
    fc = Wihajster::GCode.format_command("Stop writing to SD card", arguments)
    write_command(fc)
  end

  # *M40* **Eject**
  # 
  # If your RepRap machine can eject the parts it has built off the bed, this command executes the eject
  # cycle.  This usually involves cooling the bed and then performing a sequence of movements that
  # remove the printed parts from it.  The X, Y and Z position of the machine at the end of this cycle
  # are undefined (though they can be found out using the M114 command, q.v.).
  # See also M240 and M241 below.
  # 
  # Arg | Description
  # --- | ---
  # X   | A X coordinate, usually to move to
  # Y   | A Y coordinate, usually to move to
  # Z   | A Z coordinate, usually to move to
  # 
  # @param args [Hash] arguments for GCode can be one of [:X, :Y, :Z]
  def eject(args={})
    fc = Wihajster::GCode.format_command("Eject", arguments)
    write_command(fc)
  end

  # *M41* **Loop**
  # 
  # If the RepRap machine was building a file from its own memory such as a local SD card (as opposed to
  # a file being transmitted to it from a host computer) this goes back to the beginning of the file and
  # runs it again.  So, for example, if your RepRap is capable of ejecting parts from its build bed then
  # you can set it printing in a loop and it will run and run.  Use with caution - the only things that
  # will stop it are: 
  #  # When you press the reset button, # When the build material runs out (if your RepRap is set up to
  # detect this), # When there''s an error (such as a heater failure).|
  def loop(args={})
    fc = Wihajster::GCode.format_command("Loop", arguments)
    write_command(fc)
  end

  # *M42* **Stop on material exhausted / Switch I/O pin**
  #
  def stop_on_material_exhausted_switch_i_o_pin(args={})
    fc = Wihajster::GCode.format_command("Stop on material exhausted / Switch I/O pin", arguments)
    write_command(fc)
  end

  # *M43* **Stand by on material exhausted**
  # 
  # If your RepRap can detect when its material runs out, this decides the behaviour when that happens. 
  # The X and Y axes are zeroed (but not Z), and then the machine shuts all motors and heaters off
  # except the heated bed, the temperature of which is maintained.  The machine will still respond to G
  # and M code commands in this state.
  # 
  # Arg | Description
  # --- | ---
  # X   | A X coordinate, usually to move to
  # Y   | A Y coordinate, usually to move to
  # Z   | A Z coordinate, usually to move to
  # 
  # @param args [Hash] arguments for GCode can be one of [:X, :Y, :Z]
  def stand_by_on_material_exhausted(args={})
    fc = Wihajster::GCode.format_command("Stand by on material exhausted", arguments)
    write_command(fc)
  end

  # *M80* **ATX Power On**
  # 
  # Turns on the ATX power supply from standby mode to fully operational mode. No-op on electronics
  # without standby mode.
  # '''Note''': some firmwares, like [[Teacup Firmware | Teacup]], handle power on/off automatically, so
  # this is redundant there.
  def atx_power_on(args={})
    fc = Wihajster::GCode.format_command("ATX Power On", arguments)
    write_command(fc)
  end

  # *M81* **ATX Power Off**
  # 
  # Turns off the ATX power supply. Counterpart to M80.
  def atx_power_off(args={})
    fc = Wihajster::GCode.format_command("ATX Power Off", arguments)
    write_command(fc)
  end

  # *M82* **set extruder to absolute mode**
  # 
  # makes the extruder interpret extrusion as absolute positions.
  # This is the default in repetier.
  def set_extruder_to_absolute_mode(args={})
    fc = Wihajster::GCode.format_command("set extruder to absolute mode", arguments)
    write_command(fc)
  end

  # *M83* **set extruder to relative mode**
  # 
  # makes the extruder interpret extrusion values as relative positions.
  def set_extruder_to_relative_mode(args={})
    fc = Wihajster::GCode.format_command("set extruder to relative mode", arguments)
    write_command(fc)
  end

  # *M84* **Stop idle hold**
  # 
  # Stop the idle hold on all axis and extruder. In some cases the idle hold causes annoying noises,
  # which can be stopped by disabling the hold. Be aware that by disabling idle hold during printing,
  # you will get quality issues. This is recommended only in between or after printjobs.
  def stop_idle_hold(args={})
    fc = Wihajster::GCode.format_command("Stop idle hold", arguments)
    write_command(fc)
  end

  # *M92* **Set axis_steps_per_unit**
  # 
  # *  Sprinter and Marlin
  # Allows programming of steps per unit of axis till the electronics are reset for the specified axis.
  # Very useful for calibration.
  # 
  # Arg | Description
  # --- | ---
  # X   | A X coordinate, usually to move to
  # 
  # @param args [Hash] arguments for GCode can be one of [:X]
  def set_axis_steps_per_unit(args={})
    fc = Wihajster::GCode.format_command("Set axis_steps_per_unit", arguments)
    write_command(fc)
  end

  # *M98* **Get axis_hysteresis_mm**
  # 
  # Report the current hysteresis values in mm for all of the axis.
  # Proposed for Marlin
  def get_axis_hysteresis_mm(args={})
    fc = Wihajster::GCode.format_command("Get axis_hysteresis_mm", arguments)
    write_command(fc)
  end

  # *M99* **Set axis_hysteresis_mm**
  # 
  # Allows programming of axis hysteresis. Mechanical pulleys, gears and threads can have hysteresis
  # when they change direction. That is, a certain number of steps occur before movement occurs. You can
  # measure how many mm are lost to hysteresis and set their values with this command. Every time an
  # axis changes direction, these extra mm will be added to compensate for the hysteresis.
  # Proposed for Marlin
  # 
  # Arg | Description
  # --- | ---
  # E   | Length of extrudate in mm. This is exactly like X, Y and Z, but for the length of filament to extrude.
  # X   | A X coordinate, usually to move to
  # Y   | A Y coordinate, usually to move to
  # Z   | A Z coordinate, usually to move to
  # 
  # @param args [Hash] arguments for GCode can be one of [:E, :X, :Y, :Z]
  def set_axis_hysteresis_mm(args={})
    fc = Wihajster::GCode.format_command("Set axis_hysteresis_mm", arguments)
    write_command(fc)
  end

  # *M104* **Set Extruder Temperature**
  # 
  # Set the temperature of the current extruder to 190<sup>o</sup>C and return control to the host
  # immediately (''i.e.'' before that temperature has been reached by the extruder). See also M109.
  # This is deprecated because temperatures should be set using the G10 and T commands (q.v.).
  # Deprecation is [[Talk:G-code#M104 .26 M109 Deprecation, G10 Introduction | subject to discussion]].
  # --[[User:Traumflug|Traumflug]] 11:33, 19 July 2012 (UTC)
  # 
  # Arg | Description
  # --- | ---
  # S   | Power parameter, such as the voltage to send to a motor
  # 
  # @param args [Hash] arguments for GCode can be one of [:S]
  def set_extruder_temperature(args={})
    fc = Wihajster::GCode.format_command("Set Extruder Temperature", arguments)
    write_command(fc)
  end

  # *M105* **Get Extruder Temperature**
  # 
  # Request the temperature of the current extruder and the build base in degrees Celsius.  The
  # temperatures are returned to the host computer.  For example, the line sent to the host in response
  # to this command looks like
  # <tt>ok T:201 B:117</tt>
  def get_extruder_temperature(args={})
    fc = Wihajster::GCode.format_command("Get Extruder Temperature", arguments)
    write_command(fc)
  end

  # *M106* **Fan On**
  # 
  # Turn on the cooling fan at half speed.
  # Mandatory parameter 'S' declares the PWM value (0-255). M106 S0 turns the fan off.
  # 
  # Arg | Description
  # --- | ---
  # S   | Power parameter, such as the voltage to send to a motor
  # 
  # @param args [Hash] arguments for GCode can be one of [:S]
  def fan_on(args={})
    fc = Wihajster::GCode.format_command("Fan On", arguments)
    write_command(fc)
  end

  # *M107* **Fan Off**
  # 
  # Deprecated. Use M106 S0 instead.
  # 
  # Arg | Description
  # --- | ---
  # S   | Power parameter, such as the voltage to send to a motor
  # 
  # @param args [Hash] arguments for GCode can be one of [:S]
  def fan_off(args={})
    fc = Wihajster::GCode.format_command("Fan Off", arguments)
    write_command(fc)
  end

  # *M108* **Set Extruder Speed**
  # 
  # Sets speed of extruder motor.
  # (Deprecated in current firmware, see M113)
  def set_extruder_speed(args={})
    fc = Wihajster::GCode.format_command("Set Extruder Speed", arguments)
    write_command(fc)
  end

  # *M109* **Set Extruder Temperature and Wait**
  #
  def set_extruder_temperature_and_wait(args={})
    fc = Wihajster::GCode.format_command("Set Extruder Temperature and Wait", arguments)
    write_command(fc)
  end

  # *M110* **Set Current Line Number**
  # 
  # Set the current line number to 123.  Thus the expected next line after this command will be 124.
  def set_current_line_number(args={})
    fc = Wihajster::GCode.format_command("Set Current Line Number", arguments)
    write_command(fc)
  end

  # *M111* **Set Debug Level**
  # 
  # Set the level of debugging information transmitted back to the host to level 6.  The level is the OR
  # of three bits:
  # <Pre>
  # *define DEBUG_ECHO (1<<0)
  # *define DEBUG_INFO (1<<1)
  # *define DEBUG_ERRORS (1<<2)
  # </pre>
  # Thus 6 means send information and errors, but don't echo commands.  (This is the RepRap default.)
  # Example: M253
  # 
  # Arg | Description
  # --- | ---
  # S   | Power parameter, such as the voltage to send to a motor
  # 
  # @param args [Hash] arguments for GCode can be one of [:S]
  def set_debug_level(args={})
    fc = Wihajster::GCode.format_command("Set Debug Level", arguments)
    write_command(fc)
  end

  # *M112* **Emergency Stop**
  # 
  # Any moves in progress are immediately terminated, then RepRap shuts down.  All motors and heaters
  # are turned off.  It can be started again by pressing the reset button on the master microcontroller.
  #  See also M0 and M1.
  def emergency_stop(args={})
    fc = Wihajster::GCode.format_command("Emergency Stop", arguments)
    write_command(fc)
  end

  # *M113* **Set Extruder PWM**
  # 
  # Set the PWM for the currently-selected extruder.  On its own this command 
  # sets RepRap to use the on-board potentiometer on the extruder controller board to set the PWM for
  # the currently-selected extruder's stepper power.  With an S field:
  # M113 S0.7
  # it causes the PWM to be set to the S value (70% in this instance).  M113 S0 turns the extruder off,
  # until an M113 command other than M113 S0 is sent.
  # 
  # Arg | Description
  # --- | ---
  # S   | Power parameter, such as the voltage to send to a motor
  # 
  # @param args [Hash] arguments for GCode can be one of [:S]
  def set_extruder_pwm(args={})
    fc = Wihajster::GCode.format_command("Set Extruder PWM", arguments)
    write_command(fc)
  end

  # *M114* **Get Current Position**
  # 
  # This causes the RepRap machine to report its current X, Y, Z and E coordinates to the host.
  # For example, the machine returns a string such as:
  # <tt>ok C: X:0.00 Y:0.00 Z:0.00 E:0.00</tt>
  # 
  # Arg | Description
  # --- | ---
  # E   | Length of extrudate in mm. This is exactly like X, Y and Z, but for the length of filament to extrude.
  # X   | A X coordinate, usually to move to
  # Y   | A Y coordinate, usually to move to
  # Z   | A Z coordinate, usually to move to
  # 
  # @param args [Hash] arguments for GCode can be one of [:E, :X, :Y, :Z]
  def get_current_position(args={})
    fc = Wihajster::GCode.format_command("Get Current Position", arguments)
    write_command(fc)
  end

  # *M115* **Get Firmware Version and Capabilities**
  # 
  # Request the Firmware Version and Capabilities of the current microcontroller 
  # The details are returned to the host computer as key:value pairs separated by spaces and terminated
  # with a linefeed.
  # sample data from firmware:
  # ok PROTOCOL_VERSION:0.1 FIRMWARE_NAME:FiveD FIRMWARE_URL:http%3A//reprap.org MACHINE_TYPE:Mendel
  # EXTRUDER_COUNT:1
  # This M115 code is inconsistently implemented, and should not be relied upon to exist, or output
  # correctly in all cases. An initial implementation was committed to svn for the FiveD Reprap firmware
  # on 11 Oct 2010.  Work to more formally define protocol versions is currently (October 2010) being
  # discussed.  See [[M115_Keywords]] for one draft set of keywords and their meanings.
  def get_firmware_version_and_capabilities(args={})
    fc = Wihajster::GCode.format_command("Get Firmware Version and Capabilities", arguments)
    write_command(fc)
  end

  # *M116* **Wait**
  # 
  # Wait for ''all'' temperatures and other slowly-changing variables to arrive at their set values. 
  # See also M109.
  def wait(args={})
    fc = Wihajster::GCode.format_command("Wait", arguments)
    write_command(fc)
  end

  # *M117* **Get Zero Position**
  # 
  # This causes the RepRap machine to report the X, Y, Z and E coordinates ''in steps not mm'' to the
  # host that it found when it last hit the zero stops for those axes.  That is to say, when you zero X,
  # the <i>x</i> coordinate of the machine when it hits the X endstop is recorded.  This value should be
  # 0, of course.  But if the machine has drifted (for example by dropping steps) then it won't be. 
  # This command allows you to measure and to diagnose such problems.  (E is included for completeness. 
  # It doesn't normally have an endstop.)
  # 
  # Arg | Description
  # --- | ---
  # E   | Length of extrudate in mm. This is exactly like X, Y and Z, but for the length of filament to extrude.
  # X   | A X coordinate, usually to move to
  # Y   | A Y coordinate, usually to move to
  # Z   | A Z coordinate, usually to move to
  # 
  # @param args [Hash] arguments for GCode can be one of [:E, :X, :Y, :Z]
  def get_zero_position(args={})
    fc = Wihajster::GCode.format_command("Get Zero Position", arguments)
    write_command(fc)
  end

  # *M118* **Negotiate Features**
  # 
  # This M-code is for future proofing. NO firmware or hostware supports this at the moment. It is used
  # in conjunction with M115's FEATURES keyword.
  # See [[Protocol_Feature_Negotiation]] for more info.
  # 
  # Arg | Description
  # --- | ---
  # P   | Time  parameter, such as a time in millimetersseconds
  # 
  # @param args [Hash] arguments for GCode can be one of [:P]
  def negotiate_features(args={})
    fc = Wihajster::GCode.format_command("Negotiate Features", arguments)
    write_command(fc)
  end

  # *M119* **Get Endstop Status**
  # 
  # Returns the current state of the configured X,Y,Z endstops. Should take into account any 'inverted
  # endstop' settings, so one can confirm that the machine is interpreting the endstops correctly.
  # 
  # Arg | Description
  # --- | ---
  # X   | A X coordinate, usually to move to
  # 
  # @param args [Hash] arguments for GCode can be one of [:X]
  def get_endstop_status(args={})
    fc = Wihajster::GCode.format_command("Get Endstop Status", arguments)
    write_command(fc)
  end

  # *M126* **Open Valve**
  # 
  # Open the extruder's valve (if it has one) and wait 500 milliseconds for it to do so.
  # 
  # Arg | Description
  # --- | ---
  # P   | Time  parameter, such as a time in millimetersseconds
  # 
  # @param args [Hash] arguments for GCode can be one of [:P]
  def open_valve(args={})
    fc = Wihajster::GCode.format_command("Open Valve", arguments)
    write_command(fc)
  end

  # *M127* **Close Valve**
  # 
  # Close the extruder's valve (if it has one) and wait 400 milliseconds for it to do so.
  # 
  # Arg | Description
  # --- | ---
  # P   | Time  parameter, such as a time in millimetersseconds
  # 
  # @param args [Hash] arguments for GCode can be one of [:P]
  def close_valve(args={})
    fc = Wihajster::GCode.format_command("Close Valve", arguments)
    write_command(fc)
  end

  # *M128* **Extruder Pressure PWM**
  # 
  # PWM value to control internal extruder pressure. S255 is full pressure.
  # 
  # Arg | Description
  # --- | ---
  # S   | Power parameter, such as the voltage to send to a motor
  # 
  # @param args [Hash] arguments for GCode can be one of [:S]
  def extruder_pressure_pwm(args={})
    fc = Wihajster::GCode.format_command("Extruder Pressure PWM", arguments)
    write_command(fc)
  end

  # *M129* **Extruder pressure off**
  # 
  # In addition to setting Extruder pressure to 0, you can turn the pressure off entirely. P400 will
  # wait 100ms to do so.
  # 
  # Arg | Description
  # --- | ---
  # P   | Time  parameter, such as a time in millimetersseconds
  # 
  # @param args [Hash] arguments for GCode can be one of [:P]
  def extruder_pressure_off(args={})
    fc = Wihajster::GCode.format_command("Extruder pressure off", arguments)
    write_command(fc)
  end

  # *M130* **Set PID P value**
  # 
  # Sets heater 0 P factor to 8.0
  # 
  # Arg | Description
  # --- | ---
  # P   | Time  parameter, such as a time in millimetersseconds
  # S   | Power parameter, such as the voltage to send to a motor
  # 
  # @param args [Hash] arguments for GCode can be one of [:P, :S]
  def set_pid_p_value(args={})
    fc = Wihajster::GCode.format_command("Set PID P value", arguments)
    write_command(fc)
  end

  # *M131* **Set PID I value**
  # 
  # Sets heater 1 I factor to 0.5
  # 
  # Arg | Description
  # --- | ---
  # P   | Time  parameter, such as a time in millimetersseconds
  # S   | Power parameter, such as the voltage to send to a motor
  # 
  # @param args [Hash] arguments for GCode can be one of [:P, :S]
  def set_pid_i_value(args={})
    fc = Wihajster::GCode.format_command("Set PID I value", arguments)
    write_command(fc)
  end

  # *M132* **Set PID D value**
  # 
  # Sets heater 0 D factor to 24.0
  # 
  # Arg | Description
  # --- | ---
  # P   | Time  parameter, such as a time in millimetersseconds
  # S   | Power parameter, such as the voltage to send to a motor
  # 
  # @param args [Hash] arguments for GCode can be one of [:P, :S]
  def set_pid_d_value(args={})
    fc = Wihajster::GCode.format_command("Set PID D value", arguments)
    write_command(fc)
  end

  # *M133* **Set PID I limit value**
  # 
  # Sets heater 0 I limit value to 264
  # 
  # Arg | Description
  # --- | ---
  # P   | Time  parameter, such as a time in millimetersseconds
  # S   | Power parameter, such as the voltage to send to a motor
  # 
  # @param args [Hash] arguments for GCode can be one of [:P, :S]
  def set_pid_i_limit_value(args={})
    fc = Wihajster::GCode.format_command("Set PID I limit value", arguments)
    write_command(fc)
  end

  # *M134* **Write PID values to EEPROM**
  #
  def write_pid_values_to_eeprom(args={})
    fc = Wihajster::GCode.format_command("Write PID values to EEPROM", arguments)
    write_command(fc)
  end

  # *M136* **Print PID settings to host**
  # 
  # print heater 0 PID parameters to host
  # 
  # Arg | Description
  # --- | ---
  # P   | Time  parameter, such as a time in millimetersseconds
  # 
  # @param args [Hash] arguments for GCode can be one of [:P]
  def print_pid_settings_to_host(args={})
    fc = Wihajster::GCode.format_command("Print PID settings to host", arguments)
    write_command(fc)
  end

  # *M140* **Bed Temperature (Fast)**
  # 
  # Set the temperature of the build bed to 55<sup>o</sup>C and return control to the host immediately
  # (''i.e.'' before that temperature has been reached by the bed).
  # 
  # Arg | Description
  # --- | ---
  # S   | Power parameter, such as the voltage to send to a motor
  # 
  # @param args [Hash] arguments for GCode can be one of [:S]
  def bed_temperature(args={})
    fc = Wihajster::GCode.format_command("Bed Temperature (Fast)", arguments)
    write_command(fc)
  end

  # *M141* **Chamber Temperature (Fast)**
  # 
  # Set the temperature of the chamber to 30<sup>o</sup>C and return control to the host immediately
  # (''i.e.'' before that temperature has been reached by the chamber).
  # 
  # Arg | Description
  # --- | ---
  # S   | Power parameter, such as the voltage to send to a motor
  # 
  # @param args [Hash] arguments for GCode can be one of [:S]
  def chamber_temperature(args={})
    fc = Wihajster::GCode.format_command("Chamber Temperature (Fast)", arguments)
    write_command(fc)
  end

  # *M142* **Holding Pressure**
  # 
  # Set the holding pressure of the bed to 1 bar.
  # The holding pressure is in bar.  For hardware which only has on/off holding, when the holding
  # pressure is zero, turn off holding, when the holding pressure is greater than zero, turn on holding.
  # 
  # Arg | Description
  # --- | ---
  # S   | Power parameter, such as the voltage to send to a motor
  # 
  # @param args [Hash] arguments for GCode can be one of [:S]
  def holding_pressure(args={})
    fc = Wihajster::GCode.format_command("Holding Pressure", arguments)
    write_command(fc)
  end

  # *M143* **Maximum hot-end temperature**
  # 
  # Set the maximum temperature of the hot-end to 275C
  # When temperature of the hot-end exceeds this value, take countermeasures, for instance an emergency
  # stop. This is to prevent hot-end damage.
  # 
  # Arg | Description
  # --- | ---
  # S   | Power parameter, such as the voltage to send to a motor
  # 
  # @param args [Hash] arguments for GCode can be one of [:S]
  def maximum_hot_end_temperature(args={})
    fc = Wihajster::GCode.format_command("Maximum hot-end temperature", arguments)
    write_command(fc)
  end

  # *M160* **Number of mixed materials**
  # 
  # Set the number of materials, N, that the current extruder can handle to the number specified.  The
  # default is 1.
  # When N >= 2, then the E field that controls extrusion requires N+1 values separated by spaces after
  # it like this: 
  # <pre>
  # M160 S4
  # G1 X90.6 Y13.8 E22.4 0.1 0.1 0.1 0.7
  # G1 X70.6 E42.4 0.0 0.0 0.0 1.0
  # G1 E42.4 1.0 0.0 0.0 0.0
  # </pre>
  # The second line moves straight to the point (90.6, 13.8) extruding 22.4mm of filament.  The mix
  # ratio at the '''end''' of the move is 0.1:0.1:0.1:0.7.
  # The third line moves back 20mm in X extruding 20mm of filament.  The mix varies linearly from
  # 0.1:0.1:0.1:0.7 to 0:0:0:1 as the move is made.
  # The fourth line has no physical effect, but sets the mix proportions for the start of the next move
  # to 1:0:0:0.
  # 
  # Arg | Description
  # --- | ---
  # E   | Length of extrudate in mm. This is exactly like X, Y and Z, but for the length of filament to extrude.
  # S   | Power parameter, such as the voltage to send to a motor
  # X   | A X coordinate, usually to move to
  # Y   | A Y coordinate, usually to move to
  # 
  # @param args [Hash] arguments for GCode can be one of [:E, :S, :X, :Y]
  def number_of_mixed_materials(args={})
    fc = Wihajster::GCode.format_command("Number of mixed materials", arguments)
    write_command(fc)
  end

  # *M190* **Wait for bed temperature to reach target temp**
  # 
  # This will wait until the bed temperature reaches 60 degrees, printing out the temperature of the hot
  # end and the bed every second.
  # 
  # Arg | Description
  # --- | ---
  # S   | Power parameter, such as the voltage to send to a motor
  # 
  # @param args [Hash] arguments for GCode can be one of [:S]
  def wait_for_bed_temperature_to_reach_target_temp(args={})
    fc = Wihajster::GCode.format_command("Wait for bed temperature to reach target temp", arguments)
    write_command(fc)
  end

  # *M206* **set home offset**
  # 
  # The values specified are added to the endstop position when the axes are referenced. The same can be
  # achieved with a G92 right after homing (G28, G161).
  # With Marlin firmware, this value can be saved to EEPROM using the M500 command.
  # A similar command is G10, aligning these two is [[Talk:G-code#M104 .26 M109 Deprecation, G10
  # Introduction | subject to discussion]].
  # 
  # Arg | Description
  # --- | ---
  # X   | A X coordinate, usually to move to
  # Y   | A Y coordinate, usually to move to
  # Z   | A Z coordinate, usually to move to
  # 
  # @param args [Hash] arguments for GCode can be one of [:X, :Y, :Z]
  def set_home_offset(args={})
    fc = Wihajster::GCode.format_command("set home offset", arguments)
    write_command(fc)
  end

  # *M207* **calibrate z axis by detecting z max length**
  # 
  # After placing the tip of the nozzle in the position you expect to be considered Z=0, issue this
  # command to calibrate the Z axis. It will perform a z axis homing routine and calculate the distance
  # traveled in this process. The result is stored in EEPROM as z_max_length. For using this calibration
  # method the machine must be using a Z MAX endstop.
  # This procedure is usually more reliable than mechanical adjustments of a Z MIN endstop.
  # 
  # Arg | Description
  # --- | ---
  # Z   | A Z coordinate, usually to move to
  # 
  # @param args [Hash] arguments for GCode can be one of [:Z]
  def calibrate_z_axis_by_detecting_z_max_length(args={})
    fc = Wihajster::GCode.format_command("calibrate z axis by detecting z max length", arguments)
    write_command(fc)
  end

  # *M208* **set axis max travel**
  # 
  # The values specified set the software limits for axis travel in the positive direction.
  # With Marlin firmware, this value can be saved to EEPROM using the M500 command.
  # 
  # Arg | Description
  # --- | ---
  # X   | A X coordinate, usually to move to
  # Y   | A Y coordinate, usually to move to
  # Z   | A Z coordinate, usually to move to
  # 
  # @param args [Hash] arguments for GCode can be one of [:X, :Y, :Z]
  def set_axis_max_travel(args={})
    fc = Wihajster::GCode.format_command("set axis max travel", arguments)
    write_command(fc)
  end

  # *M209* **enable automatic retract**
  # 
  # This boolean value S 1=true or 0=false enables automatic retract detect if the slicer did not
  # support G10/11: every normal extrude-only move will be classified as retract depending on the
  # direction.
  # 
  # Arg | Description
  # --- | ---
  # S   | Power parameter, such as the voltage to send to a motor
  # 
  # @param args [Hash] arguments for GCode can be one of [:S]
  def enable_automatic_retract(args={})
    fc = Wihajster::GCode.format_command("enable automatic retract", arguments)
    write_command(fc)
  end

  # *M220* **set speed factor override percentage**
  # 
  # S<factor in percent>- set speed factor override percentage
  # 
  # Arg | Description
  # --- | ---
  # S   | Power parameter, such as the voltage to send to a motor
  # 
  # @param args [Hash] arguments for GCode can be one of [:S]
  def set_speed_factor_override_percentage(args={})
    fc = Wihajster::GCode.format_command("set speed factor override percentage", arguments)
    write_command(fc)
  end

  # *M221* **set extrude factor override percentage**
  # 
  # S<factor in percent>- set extrude factor override percentage
  # 
  # Arg | Description
  # --- | ---
  # S   | Power parameter, such as the voltage to send to a motor
  # 
  # @param args [Hash] arguments for GCode can be one of [:S]
  def set_extrude_factor_override_percentage(args={})
    fc = Wihajster::GCode.format_command("set extrude factor override percentage", arguments)
    write_command(fc)
  end

  # *M226* **Gcode Initiated Pause**
  # 
  # Initiates a pause in the same way as if the pause button is pressed. That is, program execution is
  # stopped and the printer waits for user interaction. This matches the behaviour of M1 in the
  # [http://www.nist.gov/manuscript-publication-search.cfm?pub_id=823374 NIST RS274NGC G-code standard]
  # and M0 in Marlin firmware.
  def gcode_initiated_pause(args={})
    fc = Wihajster::GCode.format_command("Gcode Initiated Pause", arguments)
    write_command(fc)
  end

  # *M229* **Enable Automatic Reverse and Prime**
  # 
  # P and S are extruder screw rotations. See also M227.
  # 
  # Arg | Description
  # --- | ---
  # P   | Time  parameter, such as a time in millimetersseconds
  # S   | Power parameter, such as the voltage to send to a motor
  # 
  # @param args [Hash] arguments for GCode can be one of [:P, :S]
  def enable_automatic_reverse_and_prime(args={})
    fc = Wihajster::GCode.format_command("Enable Automatic Reverse and Prime", arguments)
    write_command(fc)
  end

  # *M228* **Disable Automatic Reverse and Prime**
  # 
  # See also M227.
  def disable_automatic_reverse_and_prime(args={})
    fc = Wihajster::GCode.format_command("Disable Automatic Reverse and Prime", arguments)
    write_command(fc)
  end

  # *M230* **Disable / Enable Wait for Temperature Change**
  # 
  # S1 Disable wait for temperature change
  # S0 Enable wait for temperature change
  # 
  # Arg | Description
  # --- | ---
  # S   | Power parameter, such as the voltage to send to a motor
  # 
  # @param args [Hash] arguments for GCode can be one of [:S]
  def disable_enable_wait_for_temperature_change(args={})
    fc = Wihajster::GCode.format_command("Disable / Enable Wait for Temperature Change", arguments)
    write_command(fc)
  end

  # *M240* **Start conveyor belt motor / Echo off**
  # 
  # The conveyor belt allows to start mass production of a part with a reprap.  
  # Echoing may be controlled in some firmwares with M111
  # <br style="clear: both" />
  def start_conveyor_belt_motor_echo_off(args={})
    fc = Wihajster::GCode.format_command("Start conveyor belt motor / Echo off", arguments)
    write_command(fc)
  end

  # *M241* **Stop conveyor belt motor / echo on**
  # 
  # Echoing may be controlled in some firmwares with M111
  def stop_conveyor_belt_motor_echo_on(args={})
    fc = Wihajster::GCode.format_command("Stop conveyor belt motor / echo on", arguments)
    write_command(fc)
  end

  # *M245* **Start cooler**
  # 
  # used to cool parts/heated-bed down after printing for easy remove of the parts after print
  def start_cooler(args={})
    fc = Wihajster::GCode.format_command("Start cooler", arguments)
    write_command(fc)
  end

  # *M246* **Stop cooler**
  #
  def stop_cooler(args={})
    fc = Wihajster::GCode.format_command("Stop cooler", arguments)
    write_command(fc)
  end

  # *M300* **Play beep sound**
  # 
  # Usage: M300 S<frequency Hz> P<duration ms>
  # 
  # Play beep sound, use to notify important events like the end of printing.
  # [http://www.3dprinting-r2c2.com/?q=content/seasons-greetings See working example on]
  # [[R2C2_RepRap_Electronics|R2C2 electronics]].
  # 
  # Arg | Description
  # --- | ---
  # P   | Time  parameter, such as a time in millimetersseconds
  # S   | Power parameter, such as the voltage to send to a motor
  # 
  # @param args [Hash] arguments for GCode can be one of [:P, :S]
  def play_beep_sound(args={})
    fc = Wihajster::GCode.format_command("Play beep sound", arguments)
    write_command(fc)
  end

  # *M301* **Set PID parameters - Hot End**
  # 
  # Sets Proportional, Integral and Derivative values for hot end, the value C refers to an extrusion
  # rate.
  # Alternate implementation
  # Example: M301 W125
  # 
  # Arg | Description
  # --- | ---
  # P   | Time  parameter, such as a time in millimetersseconds
  # 
  # @param args [Hash] arguments for GCode can be one of [:P]
  def set_pid_parameters_hot_end(args={})
    fc = Wihajster::GCode.format_command("Set PID parameters - Hot End", arguments)
    write_command(fc)
  end

  # *M304* **Set PID parameters - Bed**
  # 
  # Sets Proportional, Integral and Derivative values for bed
  # 
  # Arg | Description
  # --- | ---
  # P   | Time  parameter, such as a time in millimetersseconds
  # 
  # @param args [Hash] arguments for GCode can be one of [:P]
  def set_pid_parameters_bed(args={})
    fc = Wihajster::GCode.format_command("Set PID parameters - Bed", arguments)
    write_command(fc)
  end

  # *M420* **Set RGB Colors as PWM**
  # 
  # Usage: M420 R<Red PWM (0-255)> E<Green PWM (0-255)> B<Blue PWM (0-255)>
  # 
  # Set the color of your RGB LEDs that are connected to PWM-enabled pins.  Note, the Green color is
  # controlled by the E value instead of the G value due to the G code being a primary code that cannot
  # be overridden.
  # 
  # Arg | Description
  # --- | ---
  # E   | Length of extrudate in mm. This is exactly like X, Y and Z, but for the length of filament to extrude.
  # R   | Temperature Parameter - used for temperatures in Celcius degrees
  # 
  # @param args [Hash] arguments for GCode can be one of [:E, :R]
  def set_rgb_colors_as_pwm(args={})
    fc = Wihajster::GCode.format_command("Set RGB Colors as PWM", arguments)
    write_command(fc)
  end

  # *T* **Select Tool**
  # 
  # Select extruder number 1 to build with.  
  # The sequence followed is:
  # 
  # * Set the current extruder to its standby temperature specified by G10 (see above),
  # * Set the new extruder to its operating temperature specified by G10 and wait for '''all'''
  # temperatures to stabilise,
  # * Apply any X, Y, Z offset for the new extruder specified by G10,
  # * Use the new extruder.
  # 
  # Selecting a non-existent tool (100, say) just does Step 1. above.  That is to say it leaves all
  # tools in their standby state.  You can, of course, use the G10 command beforehand to set that
  # standby temperature to anything you like.
  # Note that you may wish to move to a parking position ''before'' executing a T command  in order to
  # allow the new extruder to reach temperature while not in contact with the print.  It is acceptable
  # for the firmware to apply a small offset (by convention -1mm in Y) to the current position when the
  # above sequence is entered to allow temperature changes to take effect just away from the parking
  # position.  Any such offset must, of course, be undone when the procedure finishes.
  # If the Z value changes in the offsets and the head moves up, then the Z move is made before the X
  # and Y moves.  If Z moves down, X and Y are done first.
  # After a reset extruders will not start heating until they are selected.  You can either put them all
  # at their standby temperature by selecting them in turn, or leave them off so they only come on
  # if/when you first use them.  The M0, M1 and M112 commands turn them all off.  You can, of course,
  # turn them all off with the M1 command, then turn some back on again.  Don't forget also to turn on
  # the heated bed (if any) if you use that trick.
  # Extruder numbering starts at 0.
  # 
  # Arg | Description
  # --- | ---
  # X   | A X coordinate, usually to move to
  # Y   | A Y coordinate, usually to move to
  # Z   | A Z coordinate, usually to move to
  # 
  # @param args [Hash] arguments for GCode can be one of [:X, :Y, :Z]
  def select_tool(args={})
    fc = Wihajster::GCode.format_command("Select Tool", arguments)
    write_command(fc)
  end

end

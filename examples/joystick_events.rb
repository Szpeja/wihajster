# encoding: utf-8
module JoystickEvents
  # Called each time module is loaded.
  def self.extended(base)
    Wihajster.ui.log :script, :extended, "Joystick events loaded. Check if ANALOG is ON :)"
    base.set_joystick_variables
  end

  def set_joystick_variables
    @extruder = 5
    @axis = 10
  end
    
  # Called ONCE when joystick button is pressed.
  def joystick_button_pressed(event)
    super # Call other event handlers

    case event.button
    when 0 # Button 1
      rectangle
    when 1 # Button 2
    
    when 2 # Button 3
    
    when 3 # Button 4
    
    when 6 # Button L1
      move Z: @axis

    when 4 # Button L2
      move Z: 0
    
    when 7 # Button R1
      move E: @extruder

    when 5 # Button R2
      move E: -@extruder

    when 8 # Button select
    
    when 9 # Button start
      move_home

    when 10 # Button Lewy Wcisk
    
    when 11 # Button Prawy Wcisk
    
    end
  end

  
  # Called when joystick hat is moved.
  #
  # Event parameters:
  #
  # hat:: (0..3)
  # direction:: [nil, :up, :down, :left, :right]
  # horizontal:: [0, -1, 1]
  # vertical:: [0, -1, 1]
  #
  def joystick_hat_moved(event)
    super # Call other event handlers

    case event.hat
    when 0 # Krzyzak
      case event.direction
      when :up
        move Y: @axis
      when :down
        move Y: 0

      when :left
        move X: @axis
      when :right
        move X: 0

      when nil
      end
    end
  end
  
  # Called when every timer tick (by default every 100 milliseconds).
  # Can be used to move based on axis position, report temperature etc.
  # 
  # Event parameters:
  # 
  # milliseconds: The time since the last tick, in milliseconds.
  # seconds: time since the last tick, in seconds. 
  #
  def clock_ticked(tick_event)
    super # Call other event handlers

    mratio = tick_event.milliseconds.to_f / 1000

    strong_axis = axis_position.dup
    strong_axis.delete_if{|axis, value| value.abs < 0.3}

    x = @feed_rate.to_f * mratio * (strong_axis[0] || 0)
    y = @feed_rate.to_f * mratio * (strong_axis[1] || 0)
    z = @feed_rate.to_f * mratio * (strong_axis[4] || 0)

    if [x,y,z].any?{|v| v.abs > 0 }
      move X: x, Y: y, Z: z
    end
  end

  Wihajster.add self
end

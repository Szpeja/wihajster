# encoding: utf-8
module PrinterCommands
  # Called each time module is loaded.
  def self.extended(base)
    Wihajster.ui.log :script, :extended, "Added printer methods."
  end

  def printer_reset
    set_units_to_millimeters 
    set_to_absolute_positioning
    fan_off
    move_home
    reset_positions
    set_feed_rate 1200
  end

  def move_home 
    move_to_origin X: 0, Y:0
    move_to_origin Z: 0
  end

  def reset_positions
    set_position X:0, Y:0, Z:0
    set_position E:0
  end

  def set_feed_rate(fr)
    move F: fr
  end
 
  def rectangle
    move_home

    move X: 10, Y:  0
    move X: 10, Y: 10
    move X:  0, Y: 10
    move X:  0, Y:  0
  end
  
  Wihajster.add self
end

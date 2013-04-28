# encoding: utf-8
module ExtraCommands
  # Called each time module is loaded.
  def self.extended(base)
    Wihajster.ui.log :script, :extended, "Added extra methods."
  end

  def move_home 
    move_to_origin
  end
  
  def rectangle
    move_home

    move X: 10, Y:  0
    move X: 10, Y: 10
    move X:  0, Y: 10
    move X:  0, Y:  0
  end
  
  Wihajster.add_event_handler(self)
end

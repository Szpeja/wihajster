# encoding: utf-8
module JoystickEvents
  # Called each time module is loaded.
  def self.included(base)
    Wihajster.ui.say "Joystick events loaded."
  end
    
  # Called ONCE when joystick button is pressed.
  def joystick_button_pressed(event)
    case event.button
    when 0 # Button 1
      ui.say "Button 1 pressed."
    
    when 1 # Button 2
      ui.say "Button 2 pressed."
    
    when 2 # Button 3
      ui.say "Button 3 pressed."
    
    when 3 # Button 4
      ui.say "Button 4 pressed."
    
    when 4 # Button L2
      ui.say "Button L2 pressed."
    
    when 5 # Button R2
      ui.say "Button R2 pressed."
    
    when 6 # Button L1
      ui.say "Button L1 pressed."
    
    when 7 # Button R1
      ui.say "Button R1 pressed."
    
    when 8 # Button select
      ui.say "Button select pressed."
    
    when 9 # Button start
      ui.say "Button start pressed."
    end
  end

  # Called every tick/frame (10 times per second) when joystick button is pressed.
  #
  # Miliseconds is number of miliseconds that passed since last tick (should be around 100).
  # This value can be used to fine tune movement.
  def joystick_button_held(event, miliseconds)
    case event.button
    when 0 # Button 1
    
    when 1 # Button 2
    
    when 2 # Button 3
    
    when 3 # Button 4
    
    when 4 # Button L2
    
    when 5 # Button R2
    
    when 6 # Button L1
    
    when 7 # Button R1
    
    when 8 # Button select
    
    when 9 # Button start
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
    case event.hat
    when 0 # Krzyzak
      case event.direction
      when :up
      when :down
      when :left
      when :right
      when nil
      end
    end
  end
  

  # Called when joystick axis position is moved.
  #
  # Event parameters 
  #
  # axis:: (0..5)
  # value:: (-1.0..1.0)
  #
  def joystick_axis_moved(event)
    case event.axis
    when 1 # Lewy Pion
    
    when 2 # Lewy Poziom
    
    when 3 # Prawy Poziom
    
    when 4 # Prawy Pion
    end
  end

  Wihajster.add_event_handler(self)
end

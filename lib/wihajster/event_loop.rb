module Wihajster::EventLoop
  def run_event_queue
    while event = @event_queue.wait
      next if event.is_a?(Rubygame::Events::JoystickAxisMoved) && event.value.abs < 0.03

      # If a button pressed event is detected, and the button is the number "1" or "2" then we do write to the serial port
      case event
      when Rubygame::Events::JoystickButtonPressed
      when Rubygame::Events::JoystickButtonReleased
      when Rubygame::Events::JoystickAxisMoved
      when Rubygame::Events::JoystickHatMoved

      end
    end
  rescue => e
    puts "Got exception in event queue!"
    puts "#{e.class}: #{e}\n  #{e.backtrace.join("\n  ")}"
    raise(e)
  end
end

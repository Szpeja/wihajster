module Wihajster::Joystick
  module Events
    # Process joystick events from Rubygame.
    #
    # Joystick events:
    #
    # * JoystickButtonPressed button: 0
    # * JoystickButtonReleased button: 0
    # * JoystickHatMoved hat: 0, :direction: :up, :horizontal: 0, :vertical: -1
    # * JoystickHatMoved hat: 0, :direction: nil, :horizontal: 0, :vertical: 0
    # * JoystickHatMoved hat: 0, :direction: :left, :horizontal: -1, :vertical: 0
    # * JoystickHatMoved hat: 0, :direction: nil, :horizontal: 0, :vertical: 0
    # * JoystickHatMoved hat: 0, :direction: :down, :horizontal: 0, :vertical: 1
    # * JoystickHatMoved hat: 0, :direction: nil, :horizontal: 0, :vertical: 0
    # * JoystickHatMoved hat: 0, :direction: :right, :horizontal: 1, :vertical: 0
    # * JoystickHatMoved hat: 0, :direction: nil, :horizontal: 0, :vertical: 0
    # * JoystickAxisMoved axis: 3, :value: 1.0  Value is from -1.0 to 10
    # * JoystickAxisMoved axis: 3, :value: -1.0 Axis number can be from 0 to 3
    #
    def process_event(event)
      super

      Wihajster.ui.log :process_event, :joystick, "Processing event #{event.name}"

      case event.name
        when :ClockTicked
          call_pressed_buttons(event) 
        when :JoystickButtonPressed
          pressed_button[event.button] = event
          joystick_button_pressed(event)
        when :JoystickButtonReleased
          pressed_button.delete(event.button)
          joystick_button_released(event)
        when :JoystickHatMoved
          joystick_hat_moved(event)
        when :JoystickAxisMoved
          axis_position[event.axis] = event.value
          joystick_axis_moved(event)
        when :JoystickBallMoved
          joystick_ball_moved(event)
      end
    rescue => e
      Wihajster.ui.exception(e)
    end

    def pressed_button
      @pressed_button ||= Hash.new
    end

    def axis_position
      @axis_position ||= Hash.new{|h, k| h[k] = 0.0 }
    end

    def joystick_button_pressed(event)  end
    def joystick_button_released(event) end
    def joystick_hat_moved(event)       end
    def joystick_axis_moved(event)      end
    def joystick_ball_moved(event)      end

    def joystick_button_held(event, milliseconds) end

    def call_pressed_buttons(tick_event)
      pressed_button.each do |button, event|
        joystick_button_held(event, tick_event.milliseconds)
      end
    end
  end
end

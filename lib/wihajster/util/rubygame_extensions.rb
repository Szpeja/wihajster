module Wihajster::RubygameExtensions
  def name
    self.class.name.split("::").last.to_sym
  end

  def attributes
    instance_variables.inject({}) do |h, var|
      unless [:@joystick_id].include?(var)
        vname = var.to_s[1..-1].to_sym
        h[vname] = instance_variable_get(var)
      end

      h
    end
  end

  def joystick_event?
    [
      Rubygame::Events::JoystickAxisMoved,
      Rubygame::Events::JoystickBallMoved,
      Rubygame::Events::JoystickButtonPressed,
      Rubygame::Events::JoystickButtonReleased,
      Rubygame::Events::JoystickHatMoved,
    ].include?(self.class)
  end
end

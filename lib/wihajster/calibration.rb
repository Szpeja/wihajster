require 'fileutils'

module Wihajster::Calibration
  def events
    @events ||= {}
  end

  def self.included(klass)
    Wihajster.ui.say "Press every button and move every hat and ball, separately. " +
      "Assign description to each one of them.\nFinish by hitting ctrl+c"
  end

  # Joystick events:
  #
  # * JoystickButtonPressed  button: 0
  # * JoystickButtonReleased button: 0
  # * JoystickHatMoved hat: 0, direction: :up, horizontal: 0, vertical: -1
  # * JoystickHatMoved hat: 0, direction: nil, horizontal: 0, vertical: 0
  # * JoystickHatMoved hat: 0, direction: :left, horizontal: -1, vertical: 0
  # * JoystickHatMoved hat: 0, direction: nil, horizontal: 0, vertical: 0
  # * JoystickHatMoved hat: 0, direction: :down, horizontal: 0, vertical: 1
  # * JoystickHatMoved hat: 0, direction: nil, horizontal: 0, vertical: 0
  # * JoystickHatMoved hat: 0, direction: :right, horizontal: 1, vertical: 0
  # * JoystickHatMoved hat: 0, direction: nil, horizontal: 0, vertical: 0
  # * JoystickAxisMoved axis: 3, value: 1.0  Value is from -1.0 to 10
  # * JoystickAxisMoved axis: 3, value: -1.0 Axis number can be from 0 to 3
  #
  def process_event(event)
    case event
    when Interrupt
      save_calibration
    else
      type = [:button, :hat, :axis, :ball].detect{|k| event.attributes[k]}
      id = event.attributes[type]

      unless events[type: type, id: id]
        ui.event(event)
        events[type: type, id: id] = ui.ask("Description: ")
      end
    end

    super
  end

  def calibration_template
    File.read(__FILE__.sub(/\.rb$/, '/template.rb.erb'))
  end

  def save_calibration
    @axis    = events.select{|k,v| k[:type] == :axis  }.map{|k,v| [k[:id], v]}.sort
    @buttons = events.select{|k,v| k[:type] == :button}.map{|k,v| [k[:id], v]}.sort
    @hats    = events.select{|k,v| k[:type] == :hat   }.map{|k,v| [k[:id], v]}.sort

    result = ERB.new(calibration_template).result(binding)

    ui.log :calibration, result

    FileUtils.mkdir_p "script"
    File.open("script/joystick_events.rb", "w") do |f|
      f.write result
    end
  end
end

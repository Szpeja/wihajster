module Wihajster::Initializers
  attr_accessor :joystick, :event_queue, :printer

  def joystick(joystick_number=nil)
    joystick_number ||= begin 
      joysticks = Rubygame::Joystick.num_joysticks.times.map do |i|
        [i, Rubygame::Joystick.get_name(i).gsub(/\s+/, ' ').strip]
      end
    
      ui.choose("Choose joystick id from:", joysticks)
    end

    if joystick_number
      @joystick = ::Rubygame::Joystick.new(joystick_number.to_i)
      ui.log :initializer, "Initialized joystick: #{@joystick.name.gsub(/\s+/, ' ').strip}"
    end
  end
  alias :initialize_joystick :joystick

  def initialize_printer(device=nil, speed=115200)
    device ||= ui.choose("Choose printer:", ::Wihajster::Printer.devices)

    @printer = device && ::Wihajster::Printer.new(device, speed)

    if @printer
      ui.log :initializer, "Initialized printer on: #{printer_device}"
    else
      ui.log :initializer, "Failed to initialize printer"
    end
  end

  def initialize_event_queue
    @event_queue = Rubygame::EventQueue.new
    @event_queue.enable_new_style_events
  end
end

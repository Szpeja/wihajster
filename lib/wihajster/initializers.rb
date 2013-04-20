module Wihajster::Initializers
  attr_accessor :joystick, :event_queue, :printer, :printer_device

  def initialize_joystick(joystick_number=nil)
    joystick_number ||= begin 
      joysticks = Rubygame::Joystick.num_joysticks.times.map do |i|
        [i, Rubygame::Joystick.get_name(i).gsub(/\s+/, ' ').strip]
      end
    
      ui.choose("Choose joystick id from:", joysticks)
    end

    if joystick_number
      @joystick = ::Rubygame::Joystick.new(joystick_number.to_i)
      ui.say "Initialized joystick: #{@joystick.name.gsub(/\s+/, ' ').strip}"
    end
  end

  def initialize_printer(device=nil, speed=115200)
    @printer_device = device || begin
      devices = `ls -1 /dev/{ACM,USB}* 2> /dev/null`.split("\n").compact
      ui.choose("Choose printer:", devices)
    end

    if printer_device
      @printer = ::SerialPort.new(@printer_device, speed, 8, 1, SerialPort::NONE)
      ui.say "Initialized printer on: #{printer_device}"
    else
      ui.say "Failed to initialize printer"
    end
  end

  def initialize_event_queue
    @event_queue = Rubygame::EventQueue.new
    @event_queue.enable_new_style_events
  end
end

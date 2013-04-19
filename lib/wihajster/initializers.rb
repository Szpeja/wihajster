module Wihajster::Initializers
  protected

  attr_accessor :joystick, :event_queue, :printer, :printer_device

  def initialize_joystick(joystick_number=nil)
    if joystick_number || Rubygame::Joystick.num_joysticks == 1
      @joystick = Rubygame::Joystick.new(joystick_number || 0)
      logger.debug "Initialized joystick: #{@joystick.name.gsub(/\s+/, ' ').strip}"
    elsif Rubygame::Joystick.num_joysticks > 1
      puts "Choose joystick id from: "
      Rubygame::Joystick.num_joysticks.times do |i|
        puts "#{i}: #{Rubygame::Joystick.get_name(i).gsub(/\s+/, ' ').strip}"
      end
    end
  end

  def initialize_printer(device=nil, speed=115200)
    self.printer_device = device ||  begin
      devices = `ls -1 /dev/{ACM,USB}* 2> /dev/null`.split("\n").compact
      if device || devices.length == 1
        devices.first
      elsif devices.length > 1
        puts "Choose printer device from: "
        devices.each{|dev| puts dev }
      end
    end

    if @printer_device
      logger.debug "Initialized printer on: #{@printer_device}"
      @printer = SerialPort.new(@printer_device, speed, 8, 1, SerialPort::NONE)
    else
      logger.debug "Failed to initialize printer"
    end
  end

  def initialize_event_queue
    @event_queue = Rubygame::EventQueue.new
    @event_queue.enable_new_style_events
  end

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
  end

  private

  def enable_reloading
    return unless Wihajster.env == :development

    callback = lambda do |modified, added, removed|
      modified.each{|path| reload(path) }
      added.each{|path| preload(path) }
      removed.each{|path| unload(path) }
    end 

    path = File.join(Wihajster.root, 'lib')
    puts "Started monitoring #{path}"
    Listen.to(path, :filter => /\.rb$/).change(&callback).start(false)
  end

  def preload(file)
    load(file)
  rescue => e
    puts "Failed loading of #{file}."
    puts "#{e.class}: #{e}"
    puts e.backtrace[0..9].join("\n")
  end

  def reload(file)
    load(file)
  rescue => e
    puts "Failed reloading of #{file}."
    puts "#{e.class}: #{e}"
    puts e.backtrace[0..9].join("\n")
  end

  def unload(file)
  end

end

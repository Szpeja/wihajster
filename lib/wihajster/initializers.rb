module Wihajster::Initializers
  attr_accessor :joystick, :event_queue, :printer

  def initialize_rubygame
    silence_stream(STDERR) do
      require 'rubygame'
    end
    
    Rubygame::Events.constants.each do |name|
      Rubygame::Events.const_get(name).send(:include, Wihajster::RubygameExtensions)
    end

    setup_rubygame

    @rubygame_ready = true
  rescue Rubygame::SDLError => e
    ui.log :initializer, "Cannot initialize rubygame becouse of: #{e}."
    ui.log :initializer, "Some features like joystick support or desktop ui will be disabled"
  end

  def rubygame_ready?
    !!@rubygame_ready
  end

  def joystick(joystick_number=nil)
    return unless rubygame_ready?

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
      ui.log :initializer, "Initialized printer on: #{device}"
    else
      ui.log :initializer, "Failed to initialize printer"
    end
  end

  def initialize_event_loop(profile="", monitor=:monitor)
    load_scripts(profile)
    monitor_scripts(profile) if monitor
  end

  def setup_rubygame
    @event_queue = Rubygame::EventQueue.new
    @event_queue.enable_new_style_events

    @clock = Rubygame::Clock.new
    @clock.target_framerate = 10

    # Adjust the assumed granularity to match the system.
    # This helps minimize CPU usage on systems with clocks
    # that are more accurate than the default granularity.
    
    ui.log :initializer, "Calibrating clock"

    @clock.calibrate
    
    # Make Clock#tick return a ClockTicked event.
    @clock.enable_tick_events
  end

  protected

  def silence_stream(stream)
    old_stream = stream.dup
    stream.reopen('log/sdl_error.log')
    stream.sync = true

    yield
  ensure
    stream.reopen(old_stream)
  end
end

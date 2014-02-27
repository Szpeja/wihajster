module Wihajster::Initializers
  attr_accessor :joystick, :event_queue, :printer

  def rubygame_ready?
    !!@rubygame_ready
  end

  def initialize_rubygame
    silence_stream(STDERR) do
      require 'rubygame'
    end
    
    Rubygame::Events.constants.each do |name|
      Rubygame::Events.const_get(name).send(:include, Wihajster::Util::RubygameExtensions)
    end

    event_loop.setup_rubygame

    @rubygame_ready = true
  rescue => e
    if defined?(Rubygame::SDLError) && e.is_a?(Rubygame::SDLError)
      ui.log :initializer, :rubygame, 
        "Cannot initialize rubygame becouse of: #{e}.\n"+
        "Some features like joystick support or desktop ui will be disabled"
    else
      raise(e)
    end
  end

  def initialize_joystick(joystick_number=nil)
    return unless rubygame_ready?

    joystick_number ||= begin 
      joysticks = Rubygame::Joystick.num_joysticks.times.map do |i|
        [i, Rubygame::Joystick.get_name(i).gsub(/\s+/, ' ').strip]
      end
    
      ui.choose("Choose joystick id from:", joysticks)
    end

    if joystick_number
      Wihajster.joystick = @joystick = ::Rubygame::Joystick.new(joystick_number.to_i)
      joy_name = @joystick.name.gsub(/\s+/, ' ').strip
      ui.log :initializer, :joystick, "Initialized joystick: #{joy_name}"
    end
  end

  def initialize_printer(device=nil, speed=115200)
    device ||= ui.choose("Choose printer:", ::Wihajster::Printer.devices)

    Wihajster.printer = @printer = device && ::Wihajster::Printer.new(device, speed: speed)

    if @printer
      ui.log :initializer, :printer, "Initialized printer on: #{device}"
    else
      ui.log :initializer, :printer, "Failed to initialize printer"
    end
  end

  def initialize_scripts(monitor=:monitor)
    scripts.load_scripts
    scripts.monitor if monitor

    scripts.scripts
  end

  protected

  def silence_stream(stream)
    old_stream = stream.dup
    if Dir.exist?("log")
      file = File.join("log", "wihajster_sdl_errors.log")
    else
      file = RbConfig::CONFIG['host_os'] =~ /mswin|mingw/ ? 'NUL:' : '/dev/null'
    end
    stream.reopen(file)
    stream.sync = true

    yield
  ensure
    stream.reopen(old_stream)
  end
end

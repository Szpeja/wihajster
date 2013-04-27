class Wihajster::EventLoop
  include Wihajster

  module DefaultHandlers
    # Process event from Rubygame.
    #
    # Does basic event processing - handles only quititng from application.
    # Should be overriden by other handlers.
    #
    # Joystick events:
    #
    # * JoystickButtonPressed {:button=>0}
    # * JoystickButtonReleased {:button=>0}
    # * JoystickHatMoved {:hat=>0, :direction=>:up, :horizontal=>0, :vertical=>-1}
    # * JoystickHatMoved {:hat=>0, :direction=>nil, :horizontal=>0, :vertical=>0}
    # * JoystickHatMoved {:hat=>0, :direction=>:left, :horizontal=>-1, :vertical=>0}
    # * JoystickHatMoved {:hat=>0, :direction=>nil, :horizontal=>0, :vertical=>0}
    # * JoystickHatMoved {:hat=>0, :direction=>:down, :horizontal=>0, :vertical=>1}
    # * JoystickHatMoved {:hat=>0, :direction=>nil, :horizontal=>0, :vertical=>0}
    # * JoystickHatMoved {:hat=>0, :direction=>:right, :horizontal=>1, :vertical=>0}
    # * JoystickHatMoved {:hat=>0, :direction=>nil, :horizontal=>0, :vertical=>0}
    # * JoystickAxisMoved {:axis=>3, :value=>1.0}  Value is from -1.0 to 10
    # * JoystickAxisMoved {:axis=>3, :value=>-1.0} Axis number can be from 0 to 3
    #
    def process_event(event)
      case event
      when Interrupt, Rubygame::Events::QuitRequested
        exit
      when Rubygame::KeyDownEvent
        case event.key
        when Rubygame::K_ESCAPE
          exit
        end
      when Rubygame::Events::ClockTicked
        clock_ticked(event) 
      end

      process_joystick_event(event)
    end

    def pressed_button
      @pressed_button ||= Hash.new
    end

    def axis_position
      @axis_position ||= Hash.new{|h, k| h[k] = 0.0}
    end

    def process_joystick_event(event)
      case event.name
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
    end

    def joystick_button_pressed(event)  end
    def joystick_button_released(event) end
    def joystick_hat_moved(event)       end
    def joystick_axis_moved(event)      end
    def joystick_ball_moved(event)      end

    def joystick_button_held(event, miliseconds) end

    def clock_ticked(tick_event)
      pressed_button.each do |button, event|
        joystick_button_held(event, tick_event.miliseconds)
      end
    end
  end

  class Runner
    include DefaultHandlers
    include Wihajster

    def initialize(event_loop)
      @running = false
      @stop = false
      @clock = event_loop.clock
      @event_queue = event_loop.event_queue
    end

    # Runs event queue with target framerate (10fps by default).
    #
    # This aproach results in lower CPU utilization then constantly
    # checking for events.
    #
    # On each event the #process_event method is called.
    # That method should be overriden to handle events.
    def run
      @running = true

      while true
        begin
          tick_event = @clock.tick

          return if @stop

          @event_queue.each do |event|
            next if event.is_a?(Rubygame::Events::JoystickAxisMoved) && event.value.abs < 0.1
            process_event(event)
          end

          process_event(tick_event)
        rescue Interrupt => e
          process_event(e)
        end
      end
    rescue => e
      Wihajster.ui.exception(e, "in event queue!")
      raise(e)
    ensure
      @running = false
    end

    def running?
      @running && !@stop
    end

    def stop
      @stop = true
    end
  end

  attr_accessor :keep_running, :runner, :runner_thread, :profile
  attr_reader :event_queue, :clock

  def initialize
    @profile = Wihajster.profile
    @keep_running = true
    @runner = Runner.new(self)
  end

  attr_writer :scripts_path
  def scripts_path
    @scripts_path ||= File.join(Wihajster.working_dir, profile)
  end

  def running?
    @keep_running && @runner && @runner.running?
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

  def load_script(script)
    ui.log :loading_script, script

    load(script)
  rescue => e
    ui.exception(e)
    false
  end

  def load_scripts
    Dir.glob(File.join(scripts_path, "*.rb")) do |script|
      load_script(script)
    end
  end

  def reload_scripts!
    reload! do
      load_scripts
    end
  end

  def monitor_scripts
    callback = lambda do |modified, added, removed|
      if removed.any?
        reload_scripts
      else
        (added + modified).uniq.each do |path|
          if load_script(path)
            ui.log :script_loaded, "Loaded script at path #{path}"
          end
        end
      end
    end 

    ui.log :scripts_monitoring, "Started monitoring #{scripts_path}"
    Listen.to(scripts_path, :filter => /\.rb$/).change(&callback).start(false)
  end

  def add_handler(event_module)
    ui.log :added_handler, event_module.to_s
    runner.extend(event_module)
  end

  def run!(non_block = false)
    @runner_thread = Thread.new do
      while @keep_running
        runner.run
      end
    end
    @runner_thread.join unless non_block

    @runner_thread
  end

  # Reloads runner
  def reload!(&on_load)
    Thread.exclusive do
      @previous_runner = runner
      @runner = Runner.new(self)
      on_load.call if on_load
      @previous_runner.stop
    end

    self
  end

  def stop
    @keep_running = false
    runner.stop
    @runner_thread.join
  end

  def stop!
    runner_thread.terminate
  end
end

class Wihajster::EventLoop
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
      pressed_buttons.each do |button, event|
        joystick_button_held(event, tick_event.miliseconds)
      end
    end
  end

  class Runner
    include DefaultHandlers

    def initialize
      @running = false
      @stop = false
    end

    # Runs event queue with target framerate (10fps by default).
    #
    # This aproach results in lower CPU utilization then constantly
    # checking for events.
    #
    # On each event the #process_event method is called.
    # That method should be overriden to handle events.
    def run
      return unless rubygame_ready?

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
      puts "Got exception in event queue!"
      puts "#{e.class}: #{e}\n  #{e.backtrace.join("\n  ")}"
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

  attr_accessor :keep_running, :runner, :runner_thread

  def initialize
    @keep_running = true
    @runner = Runner.new
  end

  def add_handler(event_module)
    runner.extend(event_module)
  end

  def run!(non_block = false)
    @runner_thread = Thread.new do
      runner.run while @keep_running
    end
    @runner_thread.wait unless non_block

    @runner_thread
  end

  def reload!
    runner.stop
  end

  def stop
    @keep_running = false
    runner.stop
  end

  def stop!
    runner_thread.terminate
  end
end

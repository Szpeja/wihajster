class Wihajster::EventLoop
  include Wihajster
  include Scripts

  attr_accessor :keep_running, :runner_thread, :profile
  attr_reader :event_queue, :clock

  def initialize
    @profile = Wihajster.profile
    @runner  = Runner.new(self)
    @keep_running = true

    trap("SIGINT") do
      runner.process_event(Interrupt.new)
      exit!
    end
  end

  def running?
    @running && @keep_running && !@stop
  end

  def handlers
    runner.__extended_modules - Runner.ancestors
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

  # Runs event queue with target framerate (10fps by default).
  #
  # This aproach results in lower CPU utilization then constantly
  # checking for events.
  #
  # On each event the #process_event method is called.
  # That method should be overriden to handle events.
  def run_event_loop
    @running = true

    while @keep_running
      begin
        tick_event = @clock.tick

        return if @stop

        @event_queue.each do |event|
          runner.process_event(event)
        end

        runner.process_event(tick_event)
      rescue Interrupt => e
        runner.process_event(e)
      end
    end
  rescue => e
    Wihajster.ui.exception(e, "in event queue!")
    raise(e)
  ensure
    @running = false
  end

  def run!(non_block = false)
    ui.log :event_loop, :running, "Running event loop"

    @runner_thread = Thread.new do
      run_event_loop
    end
    @runner_thread.join unless non_block

    @runner_thread
  end

  # Reloads runner
  def reload!(&on_load)
    ui.log :event_loop, :reloading, "Reloading event loop"

    Thread.exclusive do
      @runner = Runner.new(self)
      on_load.call if on_load
    end

    self
  end

  def stop
    ui.log :event_loop, :stopping, "Stopping event loop"

    @keep_running = false
    @runner_thread.join
  end

  def stop!
    runner_thread.terminate
  end

  def add_handler(event_module)
    ui.log :event_loop, :added_handler, event_module.to_s
    runner.extend(event_module)
  end
end

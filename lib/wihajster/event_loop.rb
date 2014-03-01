class Wihajster::EventLoop
  include Wihajster

  attr_accessor :keep_running, :runner_thread
  attr_reader :event_queue, :clock

  class Clock
    def initialize(framerate = 25)
      @frame_rate = framerate
      @frame_time = 1.0 / @frame_rate
    end

    def tick
      @last_tick ||= Time.now
      if (wait = @last_tick + @frame_time - Time.now) > 0
        sleep wait
      end

      tick = Time.now
      @elapsed = tick - @last_tick
      @last_tick = tick

      self
    end

    def milliseconds
      (@elapsed * 1000).to_i
    end

    def seconds
      @elapsed.floor.to_i
    end
  end

  def initialize
    @keep_running = true
    @running = false
  end

  def running?
    @running && @keep_running
  end

  def setup_rubygame
    @event_queue = Rubygame::EventQueue.new
    @event_queue.enable_new_style_events

    @clock = Clock.new(25)
  end

  # More precise but seems to cause a major lag in pry, and blocks ruby threads.
  def rubygame_clock
    @clock = Rubygame::Clock.new
    @clock.target_framerate = 10
    @clock.nice = true
    @clock.granularity = 0

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

    Wihajster.ui.log :event_loop, :start, "Started Event Loop"
    while @keep_running
      begin
        tick_event = @clock.tick

        break unless @keep_running

        @event_queue.each do |event|
          runner.process_event(event)
        end

        runner.process_event(tick_event)
      rescue Interrupt => e
        @keep_running = false
      end
    end
    Wihajster.ui.log :event_loop, :finished, "Finished Event Loop"
  rescue => e
    Wihajster.ui.exception(e, "in event queue!")
    raise(e)
  ensure
    @running = false
  end

  def run!(non_block = false)
    ui.log :event_loop, :running, "Running event loop"

    @runner_thread = Util::VerboseThread.new "Event Loop" do
      @keep_running = true
      run_event_loop
    end
    @runner_thread.join unless non_block

    @runner_thread
  end

  # walling with *and_wait* leads to a nasty lock issue that will hang process
  # if called from the main thread (eg. in trap code)
  def stop(and_wait=false)
    ui.log :event_loop, :stopping, "Stopping event loop"

    @keep_running = false
    @runner_thread.join if and_wait
  end

  def stop!
    runner_thread.terminate
  end
end

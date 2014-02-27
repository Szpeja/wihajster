module Wihajster::Util::PryConsole
  def self.start(background = false)
    @rerun = true
    
    while @rerun
      @rerun = false

      @pry_thread = Util::VerboseThread("Pry").new{ Wihajster.runner.pry }
      @pry_thread.join unless background
    end
  end

  # Initializes a new runner. Stopping pry thread of previous runner.
  def self.reset
    if @pry_thread
      @rerun = true
      stop
    end
  end

  def self.stop
    @pry_thread.terminate
  end
end

module Wihajster::Util::PryConsole
  def self.start
    @rerun = true
    @pry = Pry.new

    while @rerun
      @rerun = false
      @pry.repl(Wihajster.runner)
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
    @pry.run_command("exit")
  end
end

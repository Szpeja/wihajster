class Wihajster::Runner
  Wihajster.load_libraries "runner"

  include Wihajster

  include Wihajster::Runner::DefaultHandlers
  include Wihajster::Runner::Printer
  include Wihajster::GCode

  # Initializes a new runner. Stoping pry thread of previous runner.
  def self.reset
    Wihajster.runner = new
    PryConsole.reset

    Wihajster.runner
  end

  trap("SIGINT") do
    Wihajster.runner.process_event(Interrupt.new)
  end

  def custom_handlers
    (class << self; self end).included_modules - self.class.ancestors
  end

end

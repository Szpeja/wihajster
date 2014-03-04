class Wihajster::Runner
  Wihajster.load_libraries "runner"

  include Wihajster

  include Wihajster::GCode::Commands
  include Wihajster::Runner::DefaultHandlers
  include Wihajster::Runner::PrinterCommands

  if Wihajster::App.instance.rubygame_ready?
    # Wihajster::Joystick::Events are also included if rubygame loads.
    include Wihajster::Joystick::Events
  end

  # Initializes a new runner. Stopping pry thread of previous runner.
  def self.reset
    Wihajster.runner = new
    Util::PryConsole.reset

    Wihajster.runner
  end

  def self.stop_on_interrupt
    Kernel.trap(:INT) do
      Wihajster.ui.log :signal, :interrupt, "Received INT. Stopping event loop"
      Wihajster.event_loop.stop
    end
  end

  def custom_handlers
    (class << self; self end).included_modules - self.class.ancestors
  end

end

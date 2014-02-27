require 'wihajster/joystick/events'

class Wihajster::Runner
  Wihajster.load_libraries "runner"

  include Wihajster

  include Wihajster::GCode
  include Wihajster::Runner::DefaultHandlers
  include Wihajster::Runner::Printer

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

  Kernel.trap(:INT) do
    Wihajster.runner.process_event(Interrupt.new)
  end

  def custom_handlers
    (class << self; self end).included_modules - self.class.ancestors
  end

end

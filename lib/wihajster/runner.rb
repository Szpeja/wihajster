class Wihajster::Runner
  Wihajster.load_libraries "runner"

  include Wihajster
  include DefaultHandlers
  include GCode

  trap("SIGINT") do
    Wihajster.runner.process_event(Interrupt.new)
  end

  def devices
    Printer.devices
  end

  def connect(device=nil, options={})
    dev = case device
      when String
        device
      when Integer
        devices[device]
      else
        ui.choose(devices)
    end

    Wihajster.printer = Printer.new(dev, options)
  end

  delegate :disconnect, :connected?, :can_write?,
    :state, :status, :reset!, :hard_reset!,
    :send_gcode, :send_to_printer,
    :to => :printer, :allow_nil => true

  def write_command(gcode_command)
    send_gcode(gcode_command)
  end

  def direct_mode!
    printer.direct_mode = true
  end

  def queued_mode!
    printer.direct_mode = false
  end

  def __handlers
    (class << self; self end).included_modules - self.class.ancestors
  end

  def __pry
    binding.pry
  end
end

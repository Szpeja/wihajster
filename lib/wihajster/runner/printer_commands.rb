module Wihajster::Runner::PrinterCommands
  PRINTER_METHODS = [
    :disconnect, :connected?, :can_write?,
    :state, :status, :reset!, :hard_reset!,
    :send_gcode, :send_to_printer,
  ]

  def devices
    Wihajster::Printer.devices
  end

  def connect(device=nil, options={})
    unless devices.present?
      ui.say "There's no printer connected"
      return
    end

    dev = case device
      when String
        device
      when Integer
        devices[device]
      else
        ui.choose('Which printer would you like to use?', devices)
      end

    Wihajster.printer = Wihajster::Printer.new(dev, options) if dev
  end

  # Implements the Wihajster::GCode#write_command
  #
  # All gcode methods will use this method to write data to connected printer
  def write_command(gcode_command)
    super
    send_gcode(gcode_command)
  end

  def direct_mode!
    with_printer do
      printer.direct_mode = true
    end
  end

  def queued_mode!
    with_printer do
      printer.direct_mode = false
    end
  end

  PRINTER_METHODS.each do |m|
    define_method(m) do |*args|
      with_printer{ printer.send(m, *args) }
    end
  end

  protected

  def with_printer
    if printer
      yield
    else
      Wihajster.ui.say("Printer is not connected. Use _connect_ method to connect to printer.")
      nil
    end
  end
end

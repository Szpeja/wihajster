module Wihajster::Runner::Printer
  PRINTER_METHODS = [
    :disconnect, :connected?, :can_write?,
    :state, :status, :reset!, :hard_reset!,
    :send_gcode, :send_to_printer,
  ]

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
    define_method(m) do
      with_printer{ printer.send(m) }
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

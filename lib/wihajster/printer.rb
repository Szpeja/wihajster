require 'thread'
require 'monitor'

class Wihajster::Printer < Monitor
  include Wihajster

  attr_reader :device, :speed, :sp

  # Setting direct mode will send commands straight to printer.
  # Without queueing and waiting for printer to confirm.
  # Should be used only for debugging.
  attr_accessor :direct_mode

  # Lists possible printer deices for Linux only right now.
  def self.devices
    Dir.glob('/dev/*{ACM,USB}*').to_a
  end

  def initialize(dev, opt={})
    super() # Create monitor mutex

    @device     = dev

    set_defaults
    set_options(opt)
  end

  def set_defaults
    # Number of commands we're allowed to send.
    # see http://reprap.org/wiki/GCODE_buffer_multiline_proposal
    @can_send    = 0
    @line_nr     = 0
    @direct_mode = false

    @send_queue  = Queue.new
    @lines       = []
  end

  # Passes options to serial port.
  #
  # possible settings:
  #
  # speed:: in bauds (default: 115200)
  # model:: [:reprap, :arduino]
  def set_options(opt)
    @speed      = opt[:speed] || 115200
    @model      = opt[:model] || :reprap

    # 0 - Blocking indefinitely, -1 nonblocking.
    @blocking   = 0
  end

  def connect
    disconnect if connected?
  
    if @sp = SerialPort.new(device, speed, 8, 1, SerialPort::NONE)
      @connected = true
      @sp.read_timeout = @blocking

      communication_thread
      hard_reset!
    end

    connected?
  end

  def disconnect
    @sp.close
  ensure
    @connected = false
  end

  def connected?
    @connected &&= !@sp.closed?
  end

  def can_write?
    connected? && (@can_send > 0 || @direct_mode)
  end

  def state
    case
    when can_write? then :ready_to_print
    when connected? then :connected
                    else :disconnected
    end
  end

  def greetings
    ['start', 'Grbl']
  end

  # Briefly pulse the RTS line low. On most arduino-based boards, 
  # this will hard reset the device.
  def reset_arduino
    @sp.dtr = 0
    @sp.rts = 0
    sleep(0.2)
    @sp.dtr = 1
    @sp.rts = 1
    sleep(0.3) #give the arduino some startup time
  end

  # Alternative reset. TODO: check which one works :D
  def reset_reprap
    @sp.dtr = 1
    sleep(0.2)
    @sp.dtr = 0
    sleep(0.3)
  end

  def hard_reset!
    case @model
    when :reprap
      reset_reprap
    when :arduino
      reset_arduino
    end

    reset!
  end

  def reset!
    @lines.clear
    @send_queue.clear
    @line_nr = 0
    @can_send = 1

    send_gcode('M101')
  end

  # Sends _raw_ line (from .gcode file) that MIGHT include gcode.
  #
  # This function checks line and if it detects gcode - uses send_gcode
  # to send it to printer.
  def send_raw_gcode(lines)
    lines.split("\n").each do line
      command = /^(\w\d+)/.match(line.strip)
      next unless command
      command = command[1].upcase.to_sym

      if command == "M110"
        reset!
      else
        send_gcode(command)
      end
    end
  end

  # send the line of gcode + any checksum/line numbering and then check/resend bad checksum lines
  # RepRap Syntax: N<linenumber> <cmd> *<chksum>\n
  # Makerbot Syntax: <cmd>\n
  # Comments: ;<comment> OR (<comment>)
  def send_gcode(gcode)
    @lines[@line_nr+=1] = gcode

    line = "N#{@line_nr} #{gcode} "
    checksum = line.each_byte.inject(0){|c, b| c ^= b }
    line = "#{line}*#{checksum}\n" #add checksum
    
    synchronize do
      if can_write?
        send_to_printer(line)
      else
        ui.log :printer, :queued, line
        @send_queue.push line
      end
    end
  end

  # Returns line without trailing spaces or nil if there's nothing to read(in non-blocking mode).
  # If blocking mode is set this call will wait indefinitely for response.
  def readline
    @sp.readline.strip
  rescue EOFError
    nil
  rescue IOError # Stream was closed during readline call
    disconnect
    nil
  end

  # Response format:
  #
  # xx [line number to resend]
  #    [T:93.2 B:22.9]
  #    [C: X:9.2 Y:125.4 Z:3.7 E:1902.5]
  #    [Some debugging or other information may be here]
  #
  # xx can be one of:
  #
  # ok - means that no error has been detected.
  # rs - means resend, and is followed by the line number to resend.
  # !! - means that a hardware fault has been detected. 
  #      The RepRap machine will shut down immediately after it has sent this message.
  #
  # The T: and B: values are the temperature of the currently-selected 
  # extruder and the bed respectively, and are only sent in response to M105.
  #
  # C: means that coordinates follow. Those are the X: Y: etc values. 
  # These are only sent in response to M114 and M117. 
  #
  # // This is some debugging or other information on a line on its own. 
  # It may be sent at any time.
  #
  def communication_loop
    while connected? && line = readline
      ui.log :printer, :received, line

      if line.starts_with?(*greetings)
        @can_send = 1
      elsif line.starts_with?("ok")
        # TODO: Implement Q: parameter from 
        # http://reprap.org/wiki/GCODE_buffer_multiline_proposal
        @can_send = 1
      elsif line.starts_with?("rs", "resend")
        # TODO: extract line number from response.
        line = @lines.length - 1 # Last command. 

        @send_queue.unshift(@lines[line])
        @can_send = 1
      end

      send_commands_from_queue
    end
  rescue => e
    puts "Got exception in event communication thread!"
    puts "#{e.class}: #{e}\n  #{e.backtrace.join("\n  ")}"
    disconnect
    raise(e)
  end

  # Sends as many commands as possible to machine.
  def send_commands_from_queue
    synchronize do
      return unless can_write?

      while @can_send > 0 && @send_queue.length > 0
        send_to_printer(@send_queue.pop)
      end
    end
  end

  # Sends single line to printer.
  def send_to_printer(line_to_send)
    synchronize do
      ui.log :printer, :sending, line_to_send

      @can_send -= 1
      @sp.write(line_to_send)
    end
  end

  def communication_thread
    @communication_thread ||= Util::VerboseThread.new("Communication Loop"){ communication_loop }
  end

  def status
    {state: state, can_send: @can_send, connected: connected?, queue: @send_queue.length}
  end

  def to_s
    status.inspect
  end
end

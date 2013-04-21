require 'thread'

class Wihajster::Printer
  attr_reader :device, :speed, :sp

  def self.devices
    Dir.glob('/dev/*{ACM,USB}*').to_a
  end

  def initialize(dev, opt={})
    @device     = dev
    @speed      = opt[:speed] || 115200
    @blocking   = 0 # Blocking indefinitely
    @line_nr    = 0
    # Number of commands we're allowed to send.
    # see http://reprap.org/wiki/GCODE_buffer_multiline_proposal
    @can_send   = 0 

    @send_queue = Queue.new
    @lines      = []
  end

  def ui
    @ui ||= WihajsterApp.instance.ui
  end

  def connect
    disconnect if connected?
  
    if @sp = SerialPort.new(device, speed, 8, 1, SerialPort::NONE)
      @connected = true
      @sp.read_timeout = @blocking

      Thread.new{ communication }
      reset_queue
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
    connected? && (@can_send > 0)
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

    reset_queue
  end

  # Alternative reset. TODO: check which one works :D
  def reset_reprap
    @sp.dtr = 1
    sleep(0.2);
    @sp.dtr = 0
    sleep(0.3);

    reset_queue
  end

  def reset_queue
    @lines.clear
    @send_queue.clear
    @line_nr = 0

    gcode('M101')
  end

  def raw_gcode(lines)
    lines.split("\n").each do line
      command = /^(\w\d+)/.match(line.strip)
      next unless command
      command = command[1].upcase.to_sym

      if command == "M110"
        reset_queue
      else
        gcode(command)
      end
    end
  end

  # send the line of gcode + any checksum/line numbering and then check/resend bad checksum lines
  # RepRap Syntax: N<linenumber> <cmd> *<chksum>\n
  # Makerbot Syntax: <cmd>\n
  # Comments: ;<comment> OR (<comment>)
  def gcode(gcode)
    @lines[@line_nr+=1] = gcode

    line = "N#{@line_nr} #{gcode} "
    checksum = line.each_byte.inject(0){|c, b| c ^= b }
    line = "#{line}*#{checksum}\n" #add checksum
    
    ui.log :queued, line

    @send_queue.push line
  end

  # Returns line without trailing spaces or nil if there's nothing to read(in non-blocking mode).
  # If blocking mode is set this call will wait indefinetelly for response.
  def readline
    @sp.readline.strip
  rescue EOFError
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
  def communication
    while connected? && line = readline
      ui.log :received, line

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

      if can_write? && @send_queue.length > 0
        to_send = [@can_send, @send_queue.length].min
        @can_send -= to_send

        to_send.times do
          line_to_send = @send_queue.pop

          ui.log :sending, line_to_send
          @sp.write(line_to_send)
        end
      end
    end
  rescue => e
    puts "Got exception in event communication thread!"
    puts "#{e.class}: #{e}\n  #{e.backtrace.join("\n  ")}"
    disconnect
    raise(e)
  end

  def status
    {state: state, can_send: @can_send, connected: connected?, queue: @send_queue.length}
  end

  def to_s
    status.inspect
  end
end

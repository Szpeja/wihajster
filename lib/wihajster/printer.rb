require 'thread'

class Wihajster::Printer
  attr_reader :device, :speed, :sp

  def self.devices
    Dir.glob('/dev/*{ACM,USB}*').to_a
  end

  def initialize(dev, speed=115200)
    @device     = dev
    @speed      = speed
    @line_nr    = 0

    @send_queue = Queue.new
  end

  def ui
    @ui ||= WihajsterApp.instance.ui
  end

  def connect
    @sp = SerialPort.new(device, speed, 8, 1, SerialPort::NONE)
    communication_thread
  end

  def greetings
    ['start', 'Grbl ']
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
    @queue.clear
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
  def communication_thread
    Thread.new do
      while connected? && line = queue.pop
        ui.log :sending, line
        @sp.write line
      end
    end
  end
end

# TODO:
# Setup a state machine. 
# Reading thread shoudl be probably separate from writing thread, but we need to synchronize - next command can be written only
# after printer is ready and/or has acknowledged previous command.
#
module Wihajster
  class Console
    include Wihajster
    include GCode::Commands

    def write_command(command)
      super
      printer && printer.send_gcode(command)
    end
  end
end

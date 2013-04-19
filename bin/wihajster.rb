#!/usr/bin/env ruby

require "rubygems"
require "bundler"

require File.expand_path '../../lib/wihajster', __FILE__

Bundler.require(:default, :opengl, Wihajster.env)
Wihajster.load_libraries

class WihajsterApp
  include Singleton

  include Parameters
  include Wihajster

  protected

  attr_accessor :joystick, :event_queue, :printer, :printer_device

  def initialize_joystick(joystick_number=nil)
    if joystick_number || Rubygame::Joystick.num_joysticks == 1
      @joystick = Rubygame::Joystick.new(joystick_number || 0)
      logger.debug "Initialized joystick: #{@joystick.name.gsub(/\s+/, ' ').strip}"
    elsif Rubygame::Joystick.num_joysticks > 1
      puts "Choose joystick id from: "
      Rubygame::Joystick.num_joysticks.times do |i|
        puts "#{i}: #{Rubygame::Joystick.get_name(i).gsub(/\s+/, ' ').strip}"
      end
    end
  end

  def initialize_printer(device=nil, speed=115200)
    self.printer_device = device ||  begin
      devices = `ls -1 /dev/{ACM,USB}* 2> /dev/null`.split("\n").compact
      if device || devices.length == 1
        devices.first
      elsif devices.length > 1
        puts "Choose printer device from: "
        devices.each{|dev| puts dev }
      end
    end

    if @printer_device
      logger.debug "Initialized printer on: #{@printer_device}"
      @printer = SerialPort.new(@printer_device, speed, 8, 1, SerialPort::NONE)
    else
      logger.debug "Failed to initialize printer"
    end
  end

  def initialize_event_queue
    @event_queue = Rubygame::EventQueue.new
    @event_queue.enable_new_style_events
  end

  def run_event_queue
    while event = @event_queue.wait
      next if event.is_a?(Rubygame::Events::JoystickAxisMoved) && event.value.abs < 0.03

      # If a button pressed event is detected, and the button is the number "1" or "2" then we do write to the serial port
      case event
      when Rubygame::Events::JoystickButtonPressed
      when Rubygame::Events::JoystickButtonReleased
      when Rubygame::Events::JoystickAxisMoved
      when Rubygame::Events::JoystickHatMoved

      end
    end
  end

  public

  def console
    enable_reloading
    pry self
  end

  def opengl
    @opengl_ui = Wihajster::Opengl::Ui.new
    @opengl_ui.init
    @opengl_ui.run
  end

  def run(serial_port=nil, joystick_number=nil, printer_speed=115200)
    enable_reloading
    initialize_joystick(joystick_number)
    initialize_printer(serial_port, printer_speed)
    initialize_event_queue
    run_event_queue
  end
end

WihajsterApp.instance.start

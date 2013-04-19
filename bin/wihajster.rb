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
  include Wihajster::Initializers

  def console
    enable_reloading
    pry self
  end

  def run(serial_port=nil, joystick_number=nil, printer_speed=115200)
    enable_reloading
    initialize_joystick(joystick_number)
    initialize_printer(serial_port, printer_speed)
    initialize_event_queue
    run_event_queue
  end

  protected

  def start
    action = ARGV[0] || "run"
    methods = self.public_methods(false)
    actions = methods.select{|m| m.to_s.include?(action) }

    if actions.length == 1
      method = actions.first
      begin                                                                                                                                                   
        self.send(method, *ARGV[1..-1])
      rescue ArgumentError => e
        puts "Could not call action #{method} - #{e}"
      end
    else
      puts "Usage: #{__FILE__} [action]"
      puts "\nActions:"
      methods.each do |a| 
        params = 
          self.method(a).parameters.map do |t, arg|
            case t
            when :req then arg.to_s
            when :opt then "[#{arg}]"
            when :rest then "[*#{arg}]"
            end
          end.join(" ")

        puts "  #{a} #{params}"
      end
    end
    
    self
  end
end

WihajsterApp.instance.start

#!/usr/bin/env ruby

require "rubygems"
require "bundler"

require File.expand_path '../..//lib/wihajster', __FILE__

Bundler.require(:default, Wihajster.env)

class WihajsterApp
  def self.start
    object = new

    action = ARGV[0] || "run"
    methods = object.public_methods(false)
    actions = methods.select{|m| m.to_s.include?(action) }

    if actions.length == 1
      method = actions.first
      begin
        object.send(method, *ARGV[1..-1])
      rescue ArgumentError => e
        puts "Could not call action #{method} - #{e}"
      end
    else
      puts "Usage: #{__FILE__} [action]"
      puts "\nActions:"
      methods.each do |a| 
        params = 
          object.method(a).parameters.map do |t, arg|
            case t
            when :req then arg.to_s
            when :opt then "[#{arg}]"
            when :rest then "[*#{arg}]"
            end
          end.join(" ")

        puts "  #{a} #{params}"
      end
    end
    
    object
  end

  def console
    enable_reloading
    pry self
  end 

  def run 
    enable_reloading
  end

  private

  def enable_reloading
    return unless Wihajster.env == :development

    callback = lambda do |modified, added, removed|
      modified.each{|path| reload(path) }
      added.each{|path| preload(path) }
      removed.each{|path| unload(path) }
    end 

    path = File.join(Wihajster.root, 'lib')
    puts "Started monitoring #{path}"
    Listen.to(path, :filter => /\.rb$/).change(&callback).start(false)
  end

  def preload(file)
    load(file)
  rescue => e
    puts "Failed loading of #{file}."
    puts "#{e.class}: #{e}"
    puts e.backtrace[0..9].join("\n")
  end

  def reload(file)
    load(file)
  rescue => e
    puts "Failed reloading of #{file}."
    puts "#{e.class}: #{e}"
    puts e.backtrace[0..9].join("\n")
  end

  def unload(file)
  end
end

WihajsterApp.start


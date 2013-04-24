$LOAD_PATH << File.dirname(__FILE__) unless $LOAD_PATH.include?(File.dirname(__FILE__))

require 'logger'
require 'bigdecimal'
require 'matrix'

module Wihajster
  module_function

  def root
    @root ||= File.expand_path "../", File.dirname(__FILE__)
  end

  def env
    (ENV["APP_ENV"] || "development").to_sym
  end

  def logger
    Logger.new($stdout)
  end

  def ui
    @ui ||= Ui.init(:console)
  end

  def event_loop
    @event_loop ||= EventLoop.new
  end

  def load_libraries(base="")
    to_load = Dir.glob(File.join(root, "lib/wihajster/#{base}", "*.rb")).to_a
    failed_path, exceptions = nil, {}
    
    while (path = to_load.shift) && (failed_path != path)
      $stderr.puts "Loading #{path.inspect}" if env == :debug
      begin
        require path
        failed_path = nil
      rescue NameError => e
        $stderr.puts "Cannot load #{path} - #{e}" if env == :debug
        # We save first failed path, so when we encounter it again, 
        # we know that loading every other lib before it failed.
        failed_path ||= path 
        exceptions[path] = e
        to_load.push(path)
      end
    end

    if failed_path
      exceptions.each_pair do |epath, exception|
        $stderr.puts "Cannot load: #{epath}"
        $stderr.puts "#{exception.class.name}: #{exception}\n  #{exception.backtrace.join("\n  ")}"
      end
      raise exceptions.values.first
    end
  end
end

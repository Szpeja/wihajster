$LOAD_PATH << File.dirname(__FILE__) unless $LOAD_PATH.include?(File.dirname(__FILE__))

require 'logger'
require 'bigdecimal'
require 'matrix'

module Wihajster
  class << self
    attr_accessor :printer
    attr_accessor :joystick
  
    attr_writer :ui
    def ui
      @ui ||= Ui.init(:console)
    end

    attr_writer :event_loop
    def event_loop
      @event_loop ||= EventLoop.new
    end

    attr_writer :logger
    def logger
      @logger ||= Logger.new($stdout)
    end

    attr_writer :root
    def root
      @root ||= File.expand_path "../", File.dirname(__FILE__)
    end

    attr_writer :env
    def env
      @env ||= (ENV["APP_ENV"] || "development").to_sym
    end

    attr_writer :working_dir
    def working_dir
      @working_dir ||= Dir.pwd
    end

    def profile=(new_profile)
      if @profile && @profile != new_profile
        raise "Changing of profile is not implemented (yet hopefully)"
      else
        @profile = new_profile || ""
      end
    end
    attr_reader :profile

    attr_writer :runner
    def runner
      @runner ||= Runner.new
    end

    attr_writer :scripts
    def scripts
      @scripts ||= Scripts.new
    end

    def configuration
      @configuration ||= Util::Configuration.new(profile)
    end

    def config
      configuration.data
    end
 
    def add(handler)
      scripts.add_handler(handler)
    end
  end

  [
    :ui, :event_loop, :logger, :config, :printer,
    :profile, :runner, :scripts,
  ].each do |attr|
    define_method(attr) do
      Wihajster.send(attr)
    end
  end

  module_function

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

    to_load
  end
end


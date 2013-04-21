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
    @ui ||= Console::Ui.new
  end

  def load_libraries
    to_load = Dir.glob(File.join(root, "lib/wihajster/*.rb")).to_a +
      Dir.glob(File.join(root, "lib/wihajster/*/*.rb")).to_a
    failed_path, exception = nil, nil
    
    while (path = to_load.shift) && (failed_path != path)
      $stderr.puts "Loading #{path.inspect}" if env == :debug
      begin
        require path
        failed_path, exception = nil, nil
      rescue NameError => e
        $stderr.puts "Cannot load #{path} - #{e}" if env == :debug
        exception = e
        to_load.push(failed_path = path)
      end
    end

    if failed_path
      $stderr.puts "Cannot load: #{failed_path}"
      $stderr.puts "#{exception.class.name}: #{exception}\n  #{exception.backtrace.join("\n  ")}"
      raise exception
    end
  end
end

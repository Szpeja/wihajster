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
    %[ typed ]
    require 'wihajster/typed'
    Dir.glob(File.join(root, "lib/wihajster/*.rb")).each do |path|
      require "wihajster/#{File.basename(path)}"
    end
  end
end

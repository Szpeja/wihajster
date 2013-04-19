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

  def load_libraries
    %w[ parameters typed geometry g_code stl opengl/geometry opengl/ui].each do |name|
      require "wihajster/#{name}"
    end
  end
end

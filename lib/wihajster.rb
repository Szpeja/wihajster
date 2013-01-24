$LOAD_PATH << File.dirname(__FILE__) unless $LOAD_PATH.include?(File.dirname(__FILE__))

module Wihajster
  module_function

  def root
    @root ||= File.expand_path "../", File.dirname(__FILE__)
  end

  def env
    (ENV["APP_ENV"] || "development").to_sym
  end

end

%w[ typed geometry g_code stl ].each do |name|
  require "wihajster/#{name}"
end

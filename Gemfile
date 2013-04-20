source "http://rubygems.org"

def osx_gem(name, *v)   gem name, *v, :require => RUBY_PLATFORM =~ /darwin/i ? name : false end
def linux_gem(name, *v) gem name, *v, :require => RUBY_PLATFORM =~ /linux/i  ? name : false end
def win_gem(name, *v)   gem name, *v, :require => RUBY_PLATFORM =~ /mswin/i  ? name : false end

# Utility gems.
gem "rake"
gem "ffi",      "~>1.1"         # Foreign Function Interface
gem "nokogiri"                  # XML Parsing.

gem "serialport", "~> 1.1"    # Communication with serial port.
gem "rubygame"                  # For Joystick control

group :development do
  # Use git version till https://github.com/pry/pry/issues/872 is not fixed in released gem.
  gem "pry", :git => "git://github.com/pry/pry.git" 

  # File system monitoring on:
  linux_gem 'rb-inotify', '~> 0.9'
  osx_gem   'rb-fsevent'
  win_gem   'rb-fchange'

  gem "guard"       # Monitoring changes to application files.
  gem "libnotify"   # Notfication
end

group :web do
  gem "rack", "~>1.1"
end

group :opengl do
  gem "ffi-opengl", :path => "vendor/ffi-opengl"
end

group :experiments do
  gem "ruby2c", :path => "vendor/ruby_to_c", :require => false
  gem "ffi-tcc", :path => "vendor/ffi-tcc"
end

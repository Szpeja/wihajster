source "http://rubygems.org"

def osx_gem(name, *v)   gem name, *v, :require => RUBY_PLATFORM =~ /darwin/i ? name : false end
def linux_gem(name, *v) gem name, *v, :require => RUBY_PLATFORM =~ /linux/i  ? name : false end
def win_gem(name, *v)   gem name, *v, :require => RUBY_PLATFORM =~ /mswin/i  ? name : false end

# Utility gems - We want them available but not required unless we want to.
def util_gem(name, *args) args.last.is_a?(Hash) && args.last.merge!(:require => false);  gem(name, *args) end

gem "ffi",        "~> 1.1"      # Foreign Function Interface
gem "nokogiri"                  # XML Parsing.

gem "serialport", "~> 1.1"      # Communication with serial port.
# gem "ruby-units"                # Unit conversion. Quantity is possible alternative (more rubish). Conflicts with Pry

util_gem "rubygame"             # For Joystick control

util_gem "ffi-opengl", :path => "vendor/ffi-opengl"

util_gem "rake"                 # Tasks
util_gem "redcarpet", '~> 1.0'   # Markdown formatting for documentation
util_gem "github-markup"
util_gem "yard"                 # Documentation generator. 

group :development do
  gem "pry"
  gem "listen"

  # File system monitoring on:
  linux_gem 'rb-inotify', '~> 0.9'
  osx_gem   'rb-fsevent'
  win_gem   'rb-fchange'

  # gem "guard"       # Monitoring changes to application files.
  # gem "guard-shell" 
  gem "libnotify"   # Notfication
end

group :test do
  gem "wrong", '~> 0.7.0'       # Testing library
end

group :web do
  gem "rack", "~>1.1"
end

group :experiments do
  # gem "ruby2c", :path => "vendor/ruby_to_c", :require => false
  # gem "ffi-tcc", :path => "vendor/ffi-tcc"
end

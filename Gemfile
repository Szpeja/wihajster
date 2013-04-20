source "http://rubygems.org"

def osx_gem(name, *v)   gem name, *v, :require => RUBY_PLATFORM =~ /darwin/i ? name : false end
def linux_gem(name, *v) gem name, *v, :require => RUBY_PLATFORM =~ /linux/i  ? name : false end
def win_gem(name, *v)   gem name, *v, :require => RUBY_PLATFORM =~ /mswin/i  ? name : false end

gem "ffi",        "~> 1.1"      # Foreign Function Interface
gem "nokogiri"                  # XML Parsing.

gem "serialport", "~> 1.1"      # Communication with serial port.
gem "rubygame"                  # For Joystick control
gem "ruby-units"                # Unit conversion. Quantity is possible alternative (more rubish).

gem "highline"                # Command line support
gem "ffi-opengl", :path => "vendor/ffi-opengl"

# Utility gems - We want them available but not required unless we want to.
def util_gem(name)      gem name, :require => false end
util_gem "rake"                 # Tasks
util_gem "yard"                 # Documentation generator. 
util_gem "redcarpet"            # Markdown formatting for documentation

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

group :experiments do
  gem "ruby2c", :path => "vendor/ruby_to_c", :require => false
  gem "ffi-tcc", :path => "vendor/ffi-tcc"
end

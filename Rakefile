require 'bundler'
require 'yard'
require 'redcarpet'

YARD::Rake::YardocTask.new do |t|
  t.files   = [
    'lib/**/*.rb', 
    'app/**/*.rb',
    '-', # Additional files separator
    'doc/*.html',
    'doc/*.md',
    'Readme.md',
  ]
  t.options += [
    '-opublic',
    '--title', "Wihajster Documentation",
    '--readme', 'Readme.md',
    '--markup-provider', 'redcarpet',
    '--markup', 'markdown',
  ]

  # -opublic --title "Wihajster Documentation" --readme 'Readme.md' --markup-provider 'redcarpet' --markup 'markdown'
  #
end

namespace :gcode do
  desc "Generate .yaml file based on wiki"
  task :wiki_to_yaml do
    module Wihajster
      class GCode
      end
    end
    load 'lib/wihajster/g_code/commands.rb'
    Wihajster::GCode::Commands.generate_yaml
  end

  desc "Generate .html documentation file based on yaml"
  task :doc do
    module Wihajster
      def self.root() File.dirname(__FILE__) end
      class GCode
      end
    end
    load 'lib/wihajster/g_code/commands.rb'
    Wihajster::GCode::Commands.generate_help
  end
end

namespace :install do
  desc "Install prerequisites on Debian"
  task :debian do
    `apt-get install libsdl1.2-dev libsdl-gfx1.2-dev libsdl-image1.2-dev libsdl-mixer1.2-dev libsdl-ttf2.0-dev`
  end
end

task :test do
  require_relative 'test/smoke.rb'
end


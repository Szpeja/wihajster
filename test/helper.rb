#!/usr/bin/env ruby

require "rubygems"
require "bundler"

require File.expand_path '../../lib/wihajster', __FILE__

unless File.exist?("Gemfile")
  ENV['BUNDLE_GEMFILE'] = File.join(Wihajster.root, "Gemfile")
end

Wihajster.env = :test

Bundler.require(:default, Wihajster.env)

class Object
  include Wrong
end

Wrong.config.color

require_relative 'helpers/ui'
Wihajster.ui = Wihajster::TestUi.new

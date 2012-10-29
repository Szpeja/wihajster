require 'pp'
require 'rubygems'

require 'bigdecimal'
require 'matrix'

load "./gl_app.rb"
load "./typed.rb"

class Point < Typed::Base
  has :x, :y, :z, Numeric

  def draw
    glVertex3f( x, y, z)
  end

  def to_a
    [x, y, z]
  end
end

class Triangle < Typed::Base
  has :e1, :e2, :e3, :kind => Point, :from => {
    Array => lambda{|a| Point.new(*a)}
  }
  
  def draw
    [e1, e2, e3].each do |e|
      e.draw
    end
  end

  def to_a
    [e1, e2, e3].map(&:to_a).flatten
  end
end

class Wajher < GlApp
  def initialize
    super("Wajher - #{ARGV[0] || "Unnamed"}")
  end

  def gl(kind)
    glBegin(kind)
    yield
  ensure
    glEnd()
  end

  def onDraw
    glTranslatef(-1.5, 0.0, -6.0);                 # Move Left 1.5 Units And Into The Screen 6.0

    gl GL_TRIANGLES do              # Drawing Using Triangles
      Point[ 0, 1, 0].draw              # Top
      Point[-1,-1, 0].draw              # Bottom Left
      Point[ 1,-1, 0].draw              # Bottom Right
    end
  end
end

if $0 == __FILE__
  Wajher.new.
    init.
    run
end

#!/usr/bin/env ruby

require 'ffi-opengl'
require 'rubygame'

# Based on https://github.com/rubygame/rubygame/blob/next/samples/demo_opengl.rb

# Load images from this directory
# Surface.autoload_dirs << File.join(Wihajster.root, "assets", "images")

class Wihajster::Ui::Desktop
  include GL
  include GLU

  include Rubygame
  include Rubygame::Events

  def initialize
    setup_screen(640, 480)

    @queue = EventQueue.new do |q|
      q.enable_new_style_events
    end

    @clock = Clock.new do |c|
      c.enable_tick_events
      c.target_framerate = 60
      c.calibrate
    end
  end

  def setup_screen( w, h, fovy=35, clip=[3,10] )
    opengl_attributes = {
      :red_size     => 8,
      :green_size   => 8,
      :blue_size    => 8,
      :depth_size   => 16,
      :doublebuffer => true,
    }

    Screen.set_opengl_attributes(opengl_attributes)

    @screen = Screen.open([w, h], :depth => 24, :opengl => true)

    glViewport( 0, 0, w, h )

    glMatrixMode( GL_PROJECTION )
    glLoadIdentity()
    gluPerspective( fovy, w/(h.to_f), clip[0], clip[1])

    glEnable(GL_DEPTH_TEST)
    glDepthFunc(GL_LESS)

    glEnable(GL_TEXTURE_2D)

    @screen
  end

  def process_events
    @queue.each do |event|
      case event
      when KeyPressed
        case event.key
        when :escape, :q
          throw :quit 
        when :c
          @cube.use_color   = !(@cube.use_color)
        when :t
          @cube.use_texture = !(@cube.use_texture)
        when :w
          @cube.wireframe   = !(@cube.wireframe)
        end
      when QuitRequested
        throw :quit
      end
    end
  end

  # Main game loop
  def go
    catch(:quit) do
      loop do
        process_events
        update( @clock.tick )
        draw
      end # loop
    end # catch
  end


  def update( tick )
    # Update animation on objects
  end

  def draw
    glClearColor(0.0, 0.0, 0.0, 1.0)
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT)

    # Draw scene

    Rubygame::GL.swap_buffers()
  end

end

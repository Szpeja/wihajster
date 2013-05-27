require_relative 'helper'

was_verbose = Wrong.config.verbose
Wrong.config.verbose = true

assert{ Wihajster }

assert{ Wihajster.load_libraries.is_a?(Array) }

assert{ Wihajster::App }
assert{ Wihajster::App.instance }

app = Wihajster::App.instance
assert{ app.send :use_profile, "testing" }
assert{ Wihajster.profile == "testing" }

app.initialize_rubygame

assert{ app.rubygame_ready? }

app.initialize_joystick(0)

assert{ app.joystick.is_a?(Rubygame::Joystick) }

assert{ app.initialize_printer }

assert{ app.initialize_scripts(false) }

Thread.new do
  sleep 0.1 
  app.event_loop.stop
end 

assert{ app.event_loop.run! }

Wrong.config.verbose = was_verbose

class Wihajster::App
  include Singleton

  include Wihajster
  include Wihajster::Initializers
  include Wihajster::Reloader

  def console(profile="")
    prepare(profile)

    initialize_scripts(profile, config.scripts.monitor)

    event_loop.run!(:in_background) if rubygame_ready?

    Wihajster.runner.__pry
  end

  def run(profile="")
    prepare(profile)

    initialize_scripts(profile, config.scripts.monitor)

    event_loop.run!
  end

  def joystick_calibration(profile="")
    prepare(profile)

    require 'wihajster/joystick/calibaration'
    Wihajster.add_event_handler Wihajster::Joystick::Calibration

    event_loop.run!
  end

  def events_test
    prepare("events_test")

    require 'wihajster/runner/events_test'
    Wihajster.add_event_handler Wihajster::Calibration::EventsTest

    event_loop.run!
  end

  def test_run
    prepare("test_run")

    Thread.new do
      sleep 0.3
      event_loop.stop
    end
    event_loop.run!
  end

  def generate
    # Use thor to generate - allows overriding etc.
    FileUtils.mkdir_p "log"
    Dir.glob(File.join(Wihajster.root, "examples", "*")) do |example|
      FileUtils.cp example, Dir.pwd
    end
  end

  protected

  def prepare(profile)
    Wihajster.profile = profile

    enable_reloading

    initialize_rubygame
    initialize_joystick(config.joystick.id)
    initialize_printer(config.printer.device, config.printer.speed)
  end
end

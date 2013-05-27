class Wihajster::App
  include Singleton

  include Wihajster
  include Wihajster::Initializers
  include Wihajster::Reloader

  def console(profile="")
    Wihajster.profile = profile
    prepare()

    initialize_scripts(profile, config.scripts.monitor)

    event_loop.run!(:in_background) if rubygame_ready?

    Wihajster::PryConsole.start
  end

  def run(profile="")
    Wihajster.profile = profile
    prepare()

    initialize_scripts(profile, config.scripts.monitor)

    event_loop.run!
  end

  def joystick_calibration(profile="")
    Wihajster.profile = profile
    prepare()

    require 'wihajster/joystick/calibration'
    Wihajster.add Wihajster::Joystick::Calibration

    event_loop.run!
  end

  def events_test
    Wihajster.profile = "events_test"
    prepare()

    require 'wihajster/runner/events_test'
    Wihajster.add Wihajster::Runner::EventsTest

    event_loop.run!
  end

  def test_run(profile="")
    Wihajster.profile = profile
    config.joystick.__hash[:id] = 0
    prepare

    initialize_scripts(profile, false)

    Thread.new do
      sleep 0.5
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

  def prepare
    enable_reloading # if config.reload_wihajster ?

    initialize_rubygame
    initialize_joystick(config.joystick.id)
    initialize_printer(config.printer.device, config.printer.speed)
  end
end

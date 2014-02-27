class Wihajster::App
  include Singleton

  include Wihajster
  include Wihajster::Initializers
  include Wihajster::Util::Reloader

  def console(profile="")
    use_profile profile
    prepare()

    initialize_scripts(config.scripts.monitor)

    event_loop.run!(:in_background) if rubygame_ready?

    Wihajster::Util::PryConsole.start
  end

  def run(profile="")
    use_profile profile
    prepare()

    initialize_scripts(config.scripts.monitor)

    Runner.stop_on_interrupt
    event_loop.run!
  end

  def joystick_calibration(profile="")
    use_profile profile
    prepare()

    require 'wihajster/joystick/calibration'
    Wihajster.add Wihajster::Joystick::Calibration

    event_loop.run!
  end

  def events_test
    use_profile "events_test"
    prepare()

    require 'wihajster/runner/events_test'
    Wihajster.add Wihajster::Runner::EventsTest

    Runner.stop_on_interrupt
    event_loop.run!
  end

  def test_run(profile="")
    use_profile profile
    config.joystick.__hash[:id] = 0
    prepare

    initialize_scripts(false)

    Util::VerboseThread.new "Event loop stopper" do
      sleep 1
      event_loop.stop
    end

    event_loop.run!
  end

  def generate
    # use thor to generate - allows overriding etc.
    FileUtils.mkdir_p "log"
    Dir.glob(File.join(Wihajster.root, "examples", "*")) do |example|
      FileUtils.cp example, Dir.pwd
    end
  end

  protected

  def use_profile(profile)
    Wihajster.profile = profile
  end

  def prepare
    enable_reloading # if config.reload_wihajster ?

    initialize_rubygame
    initialize_joystick(config.joystick.id)
    initialize_printer(config.printer.device, config.printer.speed)

    self
  end
end

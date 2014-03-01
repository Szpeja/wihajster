require 'singleton'

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

    finalize()
  end

  def run(profile="")
    use_profile profile
    prepare()

    initialize_scripts(config.scripts.monitor)

    Runner.stop_on_interrupt
    event_loop.run!

    finalize()
  end

  def joystick_calibration(profile="")
    use_profile profile
    prepare()

    Wihajster.add Wihajster::Runner::JoystickCalibration

    event_loop.run!

    finalize()
  end

  def events_test
    use_profile "events_test"
    prepare()

    Wihajster.add Wihajster::Runner::EventsTest

    Runner.stop_on_interrupt
    event_loop.run!

    finalize()
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

  def finalize
    Wihajster.ui.log :finalize, :event_loop, "Stopping"
    Wihajster.event_loop.stop

    Wihajster.ui.log :finalize, :scripts, :reloader, "Stopping Listen"
    Listen.stop

    Wihajster.event_loop.runner_thread.join
  end
end

class Wihajster::Scripts
  include Wihajster

  attr_accessor :profile

  def initialize(profile=nil)
    @profile = profile || Wihajster.profile
  end

  attr_writer :scripts_path
  def scripts_path
    @scripts_path ||= File.join(Wihajster.working_dir, profile)
  end

  def scripts
    Dir.glob(File.join(scripts_path, "*.rb"))
  end

  def add_handler(event_module)
    ui.log :scripts, :added_handler, event_module.to_s
    runner.extend(event_module)
  end

  def load_script(script)
    ui.log :script, :loading, script

    load(script)

    ui.log :script, :loaded, script
  rescue => e
    ui.exception(e)
    false
  end

  def load_scripts
    ui.log :scripts, :loading, "Loading scripts at #{scripts_path}"

    scripts.each do |script|
      load_script(script)
    end
  end

  def reload_scripts!
    Util::VerboseThread.exclusive("reload_scripts!") do
      Runner.reset
      load_scripts
    end
  end

  def monitor
    callback = lambda do |modified, added, removed|
      begin
        if removed.any?
          reload_scripts!
        else
          (added + modified).uniq.each do |path|
            load_script(path)
          end
        end
      rescue => e
        ui.exception(e)
      end
    end 

    ui.log :scripts, :monitoring, "Started monitoring #{scripts_path}"
    Listen.to(scripts_path, only: /\.rb$/, &callback).start
  end
end

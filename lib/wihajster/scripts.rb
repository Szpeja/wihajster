module Wihajster::Scripts
  attr_writer :scripts_path
  def scripts_path
    @scripts_path ||= File.join(Wihajster.working_dir, profile)
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

    Dir.glob(File.join(scripts_path, "*.rb")) do |script|
      load_script(script)
    end
  end

  def reload_scripts!
    reload! do
      load_scripts
    end
  end

  def monitor_scripts
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
    Listen.to(scripts_path, :filter => /\.rb$/).change(&callback).start(false)
  end
end

module Wihajster::Util::Reloader
  def enable_reloading
    return unless Wihajster.env == :development

    callback = lambda do |modified, added, removed|
      modified.each{|path| reload(path) }
      added.each{|path| preload(path) }
      removed.each{|path| unload(path) }
    end 

    path = File.join(Wihajster.root, 'lib')
    puts "Started monitoring #{path}"
    Listen.to(path, only: /\.rb$/, &callback).start
  end

  def preload(file)
    $stdout.print "Loading #{file} ..."; $stdout.flush if $stdout.respond_to?(:flush)
    load(file)
    puts "Done."
  rescue => e
    puts "Failed loading of #{file}."
    puts "#{e.class}: #{e}"
    puts e.backtrace[0..9].join("\n")
  end

  def reload(file)
    $stdout.print "Reoading #{file} ..."; $stdout.flush if $stdout.respond_to?(:flush)
    load(file)
    puts "Done."
  rescue => e
    puts "Failed reloading of #{file}."
    puts "#{e.class}: #{e}"
    puts e.backtrace[0..9].join("\n")
  end

  def unload(file)
  end
end

# More info at https://github.com/guard/guard#readme

guard :shell do
  watch(/commands\.wiki/) do
    `rake gcode:wiki_to_yaml`
  end

  watch(/commands\.yml/) do
    `rake gcode:doc`
  end

  watch(/doc\/.+/) do
    `rake yaml`
  end

  watch(%r{lib/.+\.rb}) do |m|
    `ruby -c #{m[0]}`
    if $? == 0
      result = `bin/wihajster test_run`
      if $? == 0
        n "Changed: #{m[0]}", "Test run works!", :success
      else
        n "Changed: #{m[0]}", "Test run failed to start!", :failed
      end
    else
      n m[0], "Invalid syntax!", :failed
    end
    
    result
  end
end

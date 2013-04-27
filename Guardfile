# More info at https://github.com/guard/guard#readme

guard :shell do
  watch(%r{lib/.+\.rb}) do |m|
    result = `bin/wihajster test_run`
    if $? == 0
      n result, "Started!", :success
    else
      n result, "Failed to start!", :failed
    end
  
    result
  end
end

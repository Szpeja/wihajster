# More info at https://github.com/guard/guard#readme

guard :shell do
  watch(%r{lib/.+\.rb}) do |m|
    `bin/wihajster test_run && echo "Started!" || echo "Failed to start!"`
  end
end

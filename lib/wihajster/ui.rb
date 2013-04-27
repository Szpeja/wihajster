module Wihajster::Ui
  def self.init(type)
    case type
    when :console
      load 'wihajster/ui/console.rb'
      @ui = Console.new
    when :desktop
      load 'wihajster/ui/desktop.rb'
    when :web
    else
      raise(ArgumentError, "Unrecognized UI type: #{Wihajster.ui_type}")
    end

    @ui
  end
end

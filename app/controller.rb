require 'Qt4'

module Wihajster
  module Ui

  end
end

load 'wihajster/ui/main.rb'

main = Wihajster::Ui::Main.new([])

hello = Qt::PushButton.new('Hello World!')
hello.resize(100, 30)
hello.show()

main.exec()

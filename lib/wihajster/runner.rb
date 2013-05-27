class Wihajster::Commander
  include Wihajster
  include Wihajster::GCode

  def __extended_modules
    (class << self; self end).included_modules
  end
end

class Wihajster::Util::VerboseThread < ::Thread
  def self.exclusive(comment, &block)
    Wihajster.ui.log(:thread, :exclusive, :entering, comment)
    super(&block)
    Wihajster.ui.log(:thread, :exclusive, :leaving, comment)
  end

  def self.new(name, &block)
    super do |*args|
      Wihajster.ui.log(:thread, :started, name)
      block.call(*args)
      Wihajster.ui.log(:thread, :stopped, name)
    end
  end
end
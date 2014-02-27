module Wihajster::Runner::DefaultHandlers
  # Process event from Rubygame.
  #
  # Does basic event processing - handles only quitting from application.
  # Should be overridden by other handlers.
  #
  def process_event(event)
    case event
    when Interrupt, Rubygame::Events::QuitRequested
      Kernel.exit
    when Rubygame::KeyDownEvent
      case event.key
      when Rubygame::K_ESCAPE
        Kernel.exit
      end
    end
  rescue => e
    Wihajster.ui.exception(e)
  end
end

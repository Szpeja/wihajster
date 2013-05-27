module Wihajster::Runner::DefaultHandlers
  # Process event from Rubygame.
  #
  # Does basic event processing - handles only quititng from application.
  # Should be overriden by other handlers.
  #
  def process_event(event)
    case event
    when Interrupt, Rubygame::Events::QuitRequested
      exit
    when Rubygame::KeyDownEvent
      case event.key
      when Rubygame::K_ESCAPE
        exit
      end
    end
  rescue => e
    Wihajster.ui.exception(e)
  end
end

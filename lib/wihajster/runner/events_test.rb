module Wihajster::Runner::EventsTest
  def process_event(event)
    unless event.is_a?(Rubygame::Events::ClockTicked)
      p event
    end

    super
  end
end

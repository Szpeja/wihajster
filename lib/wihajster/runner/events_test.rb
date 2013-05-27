module Wihajster::Runner::EventsTest
  def process_event(event)
    p(event) unless event.is_a? Rubygame::Events::ClockTicked

    super
  end
end

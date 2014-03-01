module Wihajster::Runner::EventsTest
  def process_event(event)
    clock_tick = event.is_a?(Rubygame::Events::ClockTicked) || event.is_a?(Wihajster::EventLoop::Clock)
    zero_axis = event.is_a?(Rubygame::Events::JoystickAxisMoved) && event.value == 0.0 && event.axis == 2
    p(event) unless clock_tick || zero_axis

    super
  end
end

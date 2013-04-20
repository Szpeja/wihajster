Integer.class_eval do
  def cm
    Unit("#{to_s} cm")
  end
end

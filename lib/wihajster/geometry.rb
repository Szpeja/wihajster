module Wihajster
  class Point < ::Typed::Base
    has :x, :y, :z, Numeric

    def *(k) Point.new(x * k, y * k, z * k) end
    def /(k) Point.new(x / k, y / k, z / k) end

    def +(o) Point.new(x + o.x, y + o.y, z + o.z) end
    def -(o) Point.new(x - o.x, y - o.y, z - o.z) end

    def r() Math.sqrt(x**2 + y**2 + z**2) end
    def normalized() self / r end

    def cross(o)
      Point.new( (y*o.z - z*o.y), (z*o.x - x*o.z), (x*o.y - y*o.x) )
    end
  end

  class Triangle < ::Typed::Base
    has :v1, :v2, :v3, Point
    has :normal_direction, Numeric, 
      :default => 1, 
      :check => lambda{|nd| ![-1, 1].include?(nd) && "direction must be either -1 or 1" }

    # Normal is calculated using right hand rule
    def normal
      u, v = (v2 - v1), (v3 - v1)

      u.cross(v).normalized * normal_direction
    end

    def points
      [v1, v2, v3]
    end
  end

  class Path < ::Typed::Base
    has :points, Array
    has :width, Numeric, :default => 1
  end
end

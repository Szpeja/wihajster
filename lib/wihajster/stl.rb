module Wihajster
  class Stl
    attr_accessor :name, :triangles

    def initialize(name="")
      @name = name
    end

    # An ASCII STL file begins with the line:
    #
    #   solid _name_
    #
    # where name is an optional string (though if name is omitted there must still be a space after solid)
    def header
      "solid #{name}"
    end

    # the file continues with any number of triangles, each represented as follows:
    #
    #   facet normal ni nj nk
    #   outer loop
    #   vertex v1x v1y v1z
    #   vertex v2x v2y v2z
    #   vertex v3x v3y v3z
    #   endloop
    #   endfacet
    #
    def body
      triangles.map(&:for_stl).join("\n")
    end

    def footer
      "endsolid #{name}"
    end

    def to_s
      header + body + footer
    end

    def inspect
      "#Wihajster::Stl[#{name.inspect}] #{triangles.count} vertices."
    end

    module FormatPoint
      # each n or v is a floating point number in sign-mantissa 'e'-sign-exponent format, e.g., "-2.648000e-002". 
      def for_stl
        [x, y, z].map{|p| "%e" % p}.join(" ")
      end
    end
    Point.send(:include, FormatPoint)

    module FormatTriangle
      #   facet normal ni nj nk
      #   outer loop
      #   vertex v1x v1y v1z
      #   vertex v2x v2y v2z
      #   vertex v3x v3y v3z
      #   endloop
      #   endfacet
      def for_stl
        [
          "facet normal #{normal.for_stl}",
          "  outer loop",
        ] + points.map{|p| "    vertex #{p.for_stl}"} + [
          "  endloop",
          "endfacet"
        ].join("\n")
      end
    end
    Triangle.send(:include, FormatTriangle)
  end
end

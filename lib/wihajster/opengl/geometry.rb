module Wihajster::Opengl
  def draw_point(p)
    glVertex3f( p.x, p.y, p.z)
  end

  def draw_triangle(t)
    gl GL_TRIANGLES do 
      [t.e1, t.e2, t.e3].each do |e|
        draw_point e
      end
    end
  end

  def draw_shape(shape)
    shape_name = shape.class.name.split("::").last.underscore
    send("draw_#{shape_name}", shape)
  end
end

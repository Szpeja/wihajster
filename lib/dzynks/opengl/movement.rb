class Wihajster::Opengl::Movement
  def initialize( options={} )
  end

  def update( tick )
    @angle += tick.seconds * 10
    @angle -= 360 if @angle >= 360
  end

  def draw
    glShadeModel(GL_SMOOTH)
    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity()

    glTranslatef( 0.0, 0.0, -4.0 )
  end
end

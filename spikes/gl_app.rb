require 'opengl'
require "mathn"

class GlApp
  include Gl,Glu, Glut

  attr_accessor :window
  attr_reader :w, :h, :title

  def initialize(t = nil, w=640, h=480)
    Gl.enable_error_checking

    @title = t || $0
    @w = w
    @h = h
  end

  def init
    # Initliaze our GLUT code
    glutInit;

    # # Setup a double buffer, RGBA color, alpha components and depth buffer
    glutInitDisplayMode(GLUT_RGB | GLUT_DOUBLE | GLUT_ALPHA | GLUT_DEPTH);
    glutInitWindowSize(@w, @h);
    glutInitWindowPosition(0, 0);

    self.window = glutCreateWindow(title);

    glutDisplayFunc(method(:draw_gl_scene).to_proc);
    glutReshapeFunc(method(:reshape).to_proc);
    glutIdleFunc(method(:idle).to_proc);
    glutKeyboardFunc(method(:keyboard).to_proc);

    init_gl_window(@w, @h)

    self
  end

  def init_gl_window(width = 640, height = 480)
    # Background color to black
    glClearColor(0.0, 0.0, 0.0, 0)
    # Enables clearing of depth buffer
    glClearDepth(1.0)
    # Set type of depth test
    glDepthFunc(GL_LEQUAL)
    # Enable depth testing
    glEnable(GL_DEPTH_TEST)
    # Enable smooth color shading
    glShadeModel(GL_SMOOTH)

    glMatrixMode(GL_PROJECTION)
    glLoadIdentity
    # Calculate aspect ratio of the window
    gluPerspective(45.0, width / height, 0.1, 100.0)

    glMatrixMode(GL_MODELVIEW)
  end

  def draw_gl_scene
    # Clear the screen and depth buffer
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

    # Reset the view
    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity

    onDraw()
    
    # Swap buffers for display 
    glutSwapBuffers
  end

  def reshape(width, height)
    height = 1 if height == 0
    
    @w = width
    @h = height

    # Reset current viewpoint and perspective transformation
    glViewport(0, 0, width, height)

    glMatrixMode(GL_PROJECTION)
    glLoadIdentity

    gluPerspective(45.0, width / height, 0.1, 100.0)
  end

  # The idle function to handle 
  def idle
    glutPostRedisplay
  end

  # Keyboard handler to exit when ESC is typed
  def keyboard(key,x,y)
    case(key)
    when ?\e
      glutDestroyWindow(window)
      exit(0)
    end
    glutPostRedisplay
  end

  def run
    draw_gl_scene

    glutMainLoop()
  end
end

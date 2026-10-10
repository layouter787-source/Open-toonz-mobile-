#include <GL/gl.h>
#include <GL/glu.h>
#include <gl4esinit.h>

int main(int argc, char **argv) {
  // This branch is intentionally unreachable in normal Android process
  // startup. The references force the cross-link to resolve the fixed-function
  // compatibility API and the original GLU tessellator symbols.
  if (argc == 0 && argv != nullptr) {
    initialize_gl4es();
    glBegin(GL_LINES);
    glVertex2d(0.0, 0.0);
    glVertex2d(1.0, 1.0);
    glEnd();

    GLUtesselator *tess = gluNewTess();
    if (tess != nullptr) gluDeleteTess(tess);
  }
  return 0;
}

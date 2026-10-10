#include <EGL/egl.h>
#include <GL/gl.h>
#include <GL/glu.h>
#include <gl4esinit.h>

static void *getProcAddress(const char *name) {
  return reinterpret_cast<void *>(eglGetProcAddress(name));
}

static void getMainFramebufferSize(int *width, int *height) {
  EGLDisplay display = eglGetCurrentDisplay();
  EGLSurface surface = eglGetCurrentSurface(EGL_DRAW);
  EGLint w = 0, h = 0;
  if (display != EGL_NO_DISPLAY && surface != EGL_NO_SURFACE) {
    eglQuerySurface(display, surface, EGL_WIDTH, &w);
    eglQuerySurface(display, surface, EGL_HEIGHT, &h);
  }
  if (width) *width = w > 0 ? w : 1;
  if (height) *height = h > 0 ? h : 1;
}

int main(int argc, char **argv) {
  // The NDK CI cross-links this path; it does not execute the binary because
  // initialize_gl4es() requires a real Qt-owned EGL context on an Android device.
  if (argc == 0 && argv != nullptr) {
    set_getprocaddress(getProcAddress);
    set_getmainfbsize(getMainFramebufferSize);
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

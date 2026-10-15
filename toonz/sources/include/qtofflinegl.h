#pragma once

#ifndef QTOFFLINEGL_H
#define QTOFFLINEGL_H

#include <memory>

#include <QOffscreenSurface>
#include <QOpenGLContext>
#include <QOpenGLFramebufferObject>

#ifndef Q_OS_ANDROID
// Desktop-only compatibility and PBuffer APIs are not present in the Android
// OpenGL ES path. QtOfflineGL below uses QOpenGLContext + an FBO instead.
#include <QtOpenGL>
#include <QGLFormat>
#include <QGLContext>
#include <QGLPixelBuffer>
#endif

#include "tofflinegl.h"

class QtOfflineGL final : public TOfflineGL::Imp {
public:
  std::shared_ptr<QOpenGLContext> m_context;
  std::shared_ptr<QOpenGLContext> m_oldContext;
  std::shared_ptr<QOffscreenSurface> m_surface;
  std::shared_ptr<QOpenGLFramebufferObject> m_fbo;

  QtOfflineGL(TDimension rasterSize, std::shared_ptr<TOfflineGL::Imp> shared);
  ~QtOfflineGL();

  void createContext(TDimension rasterSize,
                     std::shared_ptr<TOfflineGL::Imp> shared) override;
  void makeCurrent() override;
  void doneCurrent() override;

  void saveCurrentContext();
  void restoreCurrentContext();

  void getRaster(TRaster32P raster) override;
};

//-----------------------------------------------------------------------------

#ifndef Q_OS_ANDROID
class QtOfflineGLPBuffer final : public TOfflineGL::Imp {
public:
  std::shared_ptr<QGLPixelBuffer> m_context;

  QtOfflineGLPBuffer(TDimension rasterSize);
  ~QtOfflineGLPBuffer();

  void createContext(TDimension rasterSize);
  void makeCurrent() override;
  void doneCurrent() override;

  void getRaster(TRaster32P raster) override;
};
#endif

#endif

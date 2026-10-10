/*
 * Android-only GLUT stroke-font compatibility for OpenToonz.
 *
 * Font geometry comes from freeglut's Roman stroke font data, used under its
 * permissive MIT/X11-style license. This small adapter deliberately avoids
 * freeglut's window/event initialization: Qt owns the Android window and EGL
 * context, while OpenToonz only needs GLUT stroke text helpers.
 */
#include <GL/freeglut.h>
#include "fg_internal.h"

extern SFG_StrokeFont fgStrokeRoman;
extern SFG_StrokeFont fgStrokeMonoRoman;

/* The original GLUT header uses addresses of these objects as opaque font IDs. */
void *glutStrokeRoman = 0;
void *glutStrokeMonoRoman = 0;
void *glutBitmap9By15 = 0;
void *glutBitmap8By13 = 0;
void *glutBitmapTimesRoman10 = 0;
void *glutBitmapTimesRoman24 = 0;
void *glutBitmapHelvetica10 = 0;
void *glutBitmapHelvetica12 = 0;
void *glutBitmapHelvetica18 = 0;

static SFG_StrokeFont *toonzStrokeFont(void *fontID) {
  if (fontID == GLUT_STROKE_ROMAN) return &fgStrokeRoman;
  if (fontID == GLUT_STROKE_MONO_ROMAN) return &fgStrokeMonoRoman;
  return 0;
}

void FGAPIENTRY glutStrokeCharacter(void *fontID, int character) {
  SFG_StrokeFont *font = toonzStrokeFont(fontID);
  if (!font || character < 0 || character >= font->Quantity) return;

  const SFG_StrokeChar *glyph = font->Characters[character];
  if (!glyph) return;

  for (int i = 0; i < glyph->Number; ++i) {
    const SFG_StrokeStrip *strip = &glyph->Strips[i];
    if (!strip->Vertices || strip->Number <= 0) continue;
    glBegin(GL_LINE_STRIP);
    for (int j = 0; j < strip->Number; ++j)
      glVertex2f(strip->Vertices[j].X, strip->Vertices[j].Y);
    glEnd();
  }
  glTranslatef(glyph->Right, 0.0f, 0.0f);
}

GLfloat FGAPIENTRY glutStrokeWidthf(void *fontID, int character) {
  SFG_StrokeFont *font = toonzStrokeFont(fontID);
  if (!font || character < 0 || character >= font->Quantity) return 0.0f;
  const SFG_StrokeChar *glyph = font->Characters[character];
  return glyph ? glyph->Right : 0.0f;
}

int FGAPIENTRY glutStrokeWidth(void *fontID, int character) {
  return (int)(glutStrokeWidthf(fontID, character) + 0.5f);
}

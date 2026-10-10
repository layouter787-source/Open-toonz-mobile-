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
extern SFG_Font fgFontFixed8x13;
extern SFG_Font fgFontFixed9x15;
extern SFG_Font fgFontHelvetica10;
extern SFG_Font fgFontHelvetica12;
extern SFG_Font fgFontHelvetica18;
extern SFG_Font fgFontTimesRoman10;
extern SFG_Font fgFontTimesRoman24;

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

static SFG_Font *toonzBitmapFont(void *fontID) {
  if (fontID == GLUT_BITMAP_8_BY_13) return &fgFontFixed8x13;
  if (fontID == GLUT_BITMAP_9_BY_15) return &fgFontFixed9x15;
  if (fontID == GLUT_BITMAP_HELVETICA_10) return &fgFontHelvetica10;
  if (fontID == GLUT_BITMAP_HELVETICA_12) return &fgFontHelvetica12;
  if (fontID == GLUT_BITMAP_HELVETICA_18) return &fgFontHelvetica18;
  if (fontID == GLUT_BITMAP_TIMES_ROMAN_10) return &fgFontTimesRoman10;
  if (fontID == GLUT_BITMAP_TIMES_ROMAN_24) return &fgFontTimesRoman24;
  return 0;
}

void FGAPIENTRY glutBitmapCharacter(void *fontID, int character) {
  SFG_Font *font = toonzBitmapFont(fontID);
  if (!font || character < 1 || character >= 256) return;
  const GLubyte *face = font->Characters[character];
  if (!face) return;

  // GL4ES translates this legacy bitmap call for the Qt-owned GLES context.
  glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
  glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
  glPixelStorei(GL_UNPACK_SKIP_ROWS, 0);
  glPixelStorei(GL_UNPACK_SKIP_PIXELS, 0);
  glPixelStorei(GL_UNPACK_SWAP_BYTES, GL_FALSE);
  glPixelStorei(GL_UNPACK_LSB_FIRST, GL_FALSE);
  glBitmap(face[0], font->Height, font->xorig, font->yorig,
           (GLfloat)face[0], 0.0f, face + 1);
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

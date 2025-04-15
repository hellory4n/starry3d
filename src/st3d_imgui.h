#ifndef _ST3D_IMGUI_H
#define _ST3D_IMGUI_H

// if you don't do that it just puts 5 billion trillion c++ crap in the header????
// like why????
// if i wanted c++ i would use c++
#define CIMGUI_DEFINE_ENUMS_AND_STRUCTS
#include <cimgui.h>

void st3d_imgui_new(void);
void st3d_imgui_free(void);

void st3d_imgui_begin(void);
void st3d_imgui_end(void);

#endif

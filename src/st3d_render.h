#ifndef _ST3D_RENDER_H
#define _ST3D_RENDER_H
#include <libtrippin.h>

#ifdef __cplusplus
extern "C" {
#endif

// Begins drawing and clears the screen
void st3d_begin_drawing(TrColor clear_color);

// Does some fuckery that ends drawing.
void st3d_end_drawing(void);

#ifdef __cplusplus
}
#endif

#endif

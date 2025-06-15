#ifndef _SANDBOX_HELLO_TRIANGLE
#define _SANDBOX_HELLO_TRIANGLE

#include <libtrippin.hpp>

namespace sandbox {

struct Vertex {
	tr::Vec3<float32> position;
	tr::Vec4<float32> color;
};

void init_triangle();
void render_triangle();

}

#endif

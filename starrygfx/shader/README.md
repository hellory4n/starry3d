# Shaders

Starry uses a GPU-driven architecture, which allows 1 shader to render (most of) an entire scene. To allow for custom shaders, the user's shader code in inserted in the middle of this ubershader. Some parts of the ubershader are also used in compute shaders. To allow for this mess to work, the engine uses fancy technology (string concatenation) to combine multiple shader files into one. Essentially a poor man's shader compiler. This will likely break your IDE.

## Concatenation order

- ubershader:
	1. `defs.glsl`
	2. `ubershader_inputs.glsl`
	3. `ubershader.vert` or `ubershader.frag`

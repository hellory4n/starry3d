package stvoxel

import gpu "../starryrt/gpu"

@(private)
global: struct {
	camera:   Camera,
	pipeline: gpu.Pipeline,
}

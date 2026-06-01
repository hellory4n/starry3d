package stvoxel

import gpu "../starryapp/gpu"

@(private)
global: struct {
	camera:   Camera,
	pipeline: gpu.Pipeline,
}

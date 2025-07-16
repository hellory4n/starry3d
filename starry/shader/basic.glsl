@vs vs
in vec3 position;

void main()
{
	gl_Position = vec4(position, 1.0);
}
@end

@fs fs
out vec4 FragColor;

void main()
{
	FragColor = vec4(1, 0, 0, 1);
}
@end

@program basic vs fs

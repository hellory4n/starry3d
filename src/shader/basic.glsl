#shader vertex
#version 330 core
layout (location = 0) in vec3 position;
layout (location = 1) in vec4 color;

out vec4 out_color;

void main()
{
    gl_Position = vec4(position, 1.0);
    out_color = color;
}

#shader fragment
#version 330 core
in vec4 out_color;

out vec4 FragColor;

void main()
{
FragColor = out_color;
}

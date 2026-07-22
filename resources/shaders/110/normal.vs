#version 110

// Writes per-fragment world-space normals into a G-buffer that the SSAO pass
// samples. The world normal matrix is provided by the volume render path via
// the same SlopeDetection uniform the phong/gouraud shaders already receive.

struct SlopeDetection
{
    bool actived;
    float normal_z;
    mat3 volume_world_normal_matrix;
};

uniform mat4 view_model_matrix;
uniform mat4 projection_matrix;
uniform SlopeDetection slope;

attribute vec3 v_position;
attribute vec3 v_normal;

varying vec3 world_normal;

void main()
{
    world_normal = slope.volume_world_normal_matrix * v_normal;
    gl_Position = projection_matrix * view_model_matrix * vec4(v_position, 1.0);
}

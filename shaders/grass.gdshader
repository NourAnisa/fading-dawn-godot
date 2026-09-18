shader_type spatial;
render_mode cull_disabled;
varying float blade_height;
varying float variation;
void vertex() {
 blade_height = clamp(VERTEX.y / 0.72, 0.0, 1.0);
 vec3 p = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
 variation = fract(sin(dot(p.xz, vec2(12.9898,78.233))) * 43758.5453);
 VERTEX.x += sin(TIME*1.5 + p.x*0.8 + p.z*0.5)*0.1*blade_height*blade_height;
}
void fragment() {
 ALBEDO = mix(vec3(0.10,0.17,0.07),vec3(0.38,0.44,0.19),blade_height) * mix(0.8,1.15,variation);
 ROUGHNESS = 0.95;
}

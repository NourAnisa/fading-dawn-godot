shader_type spatial;
uniform vec4 dark_color : source_color = vec4(0.2, 0.25, 0.2, 1.0);
uniform vec4 light_color : source_color = vec4(0.5, 0.5, 0.4, 1.0);
uniform float frequency = 1.0;
varying vec3 world_pos;
float hash(vec3 p) { return fract(sin(dot(p, vec3(127.1,311.7,74.7))) * 43758.5453); }
float noise(vec3 p) {
 vec3 i = floor(p); vec3 f = fract(p); f = f*f*(3.0-2.0*f);
 return mix(mix(mix(hash(i),hash(i+vec3(1,0,0)),f.x),mix(hash(i+vec3(0,1,0)),hash(i+vec3(1,1,0)),f.x),f.y),
 mix(mix(hash(i+vec3(0,0,1)),hash(i+vec3(1,0,1)),f.x),mix(hash(i+vec3(0,1,1)),hash(i+vec3(1,1,1)),f.x),f.y),f.z);
}
void vertex() { world_pos = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz; }
void fragment() {
 float n = noise(world_pos*frequency)*0.6 + noise(world_pos*frequency*5.0)*0.28 + noise(world_pos*frequency*23.0)*0.12;
 ALBEDO = mix(dark_color.rgb,light_color.rgb,n);
 ROUGHNESS = 0.92;
}

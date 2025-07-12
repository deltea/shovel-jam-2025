shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

uniform int num_colors;
uniform sampler2D palette_in;
uniform sampler2D palette_out;
uniform float precision : hint_range(0.0, 1.0, 0.1) = 0.1;

vec4 swap_color(vec4 color) {
  float inc = 1.0 / float(num_colors);
  for (float i = 0.0; i < 1.0; i += inc) {
    vec2 uv = vec2(i + (inc / 2.0), 0.0);
    vec4 color_in = texture(palette_in, uv);
    if (distance(color, color_in) <= precision) {
      return texture(palette_out, uv);
    }
  }
}

void fragment() {
	vec4 color = texture(screen_texture, SCREEN_UV);
	COLOR = swap_color(color);
}

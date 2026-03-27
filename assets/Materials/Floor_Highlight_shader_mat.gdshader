shader_type canvas_item;

const float scale = 0.03125; // 1/32 for 32px tiles

uniform sampler2D overlay_texture: repeat_enable, filter_nearest;
uniform vec4 color : source_color;
uniform float pulse_speed = 1.0;
uniform float base_opacity = 0.1;
uniform float highlight_opacity = 0.9;
uniform float distance_scaling = 32.0;
uniform vec2 mouse_position;// = vec2(16.0,16.0);

varying vec2 world_position;

void vertex(){
    world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}


void fragment() {
	float pulse_factor = pow(sin(TIME * pulse_speed), 2);
	
    vec4 texColor = texture(TEXTURE, UV);
    vec4 grid_color = texture(overlay_texture, world_position * scale) * color;
	grid_color = vec4(grid_color.rgb, grid_color.a * pulse_factor);
    float distance_to_mouse = distance(mouse_position, world_position);
    float normalized = 1.0 - (clamp(distance_to_mouse, 0, distance_scaling) / distance_scaling);
    COLOR = mix(texColor, grid_color, grid_color.a * (base_opacity + highlight_opacity * normalized));
	//COLOR = mix(color, grid_color, grid_color.a * (base_opacity + highlight_opacity * 1.0));
}
shader_type canvas_item;
render_mode blend_disabled;

void fragment(){
	vec4 color = texture(TEXTURE,UV);
	vec3 color_fix = color.rgb/color.a/color.a;
	COLOR = vec4(color_fix,color.a);
}
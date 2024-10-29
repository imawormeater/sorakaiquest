shader_type spatial;
render_mode unshaded,cull_front;

uniform sampler2D tex;

uniform vec4 albedo_color:source_color = vec4(1.0);
uniform float scale = 1.0;
uniform float rotation_speed = 1.0;

void vertex(){
	float time = TIME * rotation_speed;
	float sine = sin(time) * scale;
	float cosine = cos(time) * scale;
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0],INV_VIEW_MATRIX[1],INV_VIEW_MATRIX[2],MODEL_MATRIX[3]);
	MODELVIEW_MATRIX[0][0] *= sine;
	MODELVIEW_MATRIX[0][1] += cosine;
	MODELVIEW_MATRIX[1][0] += cosine;
	MODELVIEW_MATRIX[1][1] *= -sine;

}

void fragment(){
	vec4 tex_samp = texture(tex,UV);
	ALBEDO = tex_samp.rgb*albedo_color.rgb;
	ALPHA = tex_samp.a*albedo_color.a;
}
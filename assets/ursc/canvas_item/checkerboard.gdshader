shader_type canvas_item;

uniform float cells = 8.0;
uniform vec2 uiscale = vec2(0.0,0.0);
uniform vec2 offset = vec2(0.0,0.0);
uniform sampler2D texcolor: source_color;

void vertex() {
	UV *= uiscale;
	UV += offset;
}

void fragment() {
	bool cell = mod(floor(UV.x * cells) + floor(UV.y * cells), 2.0) == 0.0;
	if (cell){
		COLOR += vec4(0.0,0.0,0.0,0.02);
	}
}
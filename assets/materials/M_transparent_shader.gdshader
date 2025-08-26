shader_type canvas_item;

uniform sampler2D texture_albedo : source_color;

void fragment() {
    vec4 tex_color = texture(texture_albedo, UV);
    if (tex_color.r < 0.2 && tex_color.g < 0.2 && tex_color.b < 0.3) {
        discard;
    }
    
    COLOR = tex_color;
}
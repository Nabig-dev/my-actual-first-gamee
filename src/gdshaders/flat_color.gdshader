shader_type canvas_item;

uniform vec4 colour : hint_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform bool active = false;
void fragment() {
    if(active == true) {

        vec4 curr_color = texture(TEXTURE,UV); // Get current color of pixel

        if (curr_color.a == 1.0f){
            COLOR.rgb = colour.rgb;//vec3(0.238, 0.118, 0.418);
        }else{
            COLOR = curr_color;
        }
    }
    else{
        COLOR = texture(TEXTURE,UV);
    }
}
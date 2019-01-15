#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

// p5-predefined values
#define PROCESSING_TEXTURE_SHADER
uniform sampler2D fg;
uniform sampler2D textile;
uniform sampler2D realtime;
uniform sampler2D bg;

uniform bvec4 texFlags;
#define fgEnabled texFlags.x
#define textileEnabled texFlags.y
#define isAlphaFg texFlags.z
#define bgEnabled texFlags.w

uniform vec2 texOffset;
varying vec4 vertColor;
varying vec4 vertTexCoord;
 
// user-configurable variables (read-only) 
uniform vec3 keying_color; 
uniform float thresh; // [0, 1.732] 
uniform float slope; // [0, 1] 
uniform vec3 weight; // (1, 0.7, 1)
uniform vec4 rect_roi;
#define X1 rect_roi.r
#define Y1 rect_roi.g
#define X2 rect_roi.b
#define Y2 rect_roi.a

uniform vec3 delta_hsv; // [-1, 1] * 3
#define delta_h delta_hsv.r
#define delta_s delta_hsv.g
#define delta_v delta_hsv.b

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
 
vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main(void)
{
	vec3 realtime_color = vec3(0);
	float alpha = 0;
	if (vertTexCoord.s > X1 &&
	vertTexCoord.t > Y1 && 
	vertTexCoord.s < X2 &&
	vertTexCoord.t < Y2 )
	{
	    realtime_color = texture2D(realtime, vertTexCoord.st).rgb;

	    float dist = distance(keying_color * weight, realtime_color * weight);
	    float edge0 = thresh * (1.0 - slope);
	    alpha = smoothstep(edge0, thresh, dist);
	    vec3 hsv = rgb2hsv(realtime_color);
	    hsv = clamp(hsv + delta_hsv, 0.0, 1.0);
	    realtime_color = hsv2rgb(hsv);
	}

    vec3 bg_color = vec3(0,0,0);
    if (bgEnabled) bg_color = texture2D(bg, vertTexCoord.st).rgb;

    vec3 rgb = mix(bg_color, realtime_color, alpha);

    if (fgEnabled)
    {
    	vec4 fg_color = texture2D(fg, vertTexCoord.st);
    	rgb = mix(rgb, fg_color.rgb, isAlphaFg ? fg_color.a : 0.3);
    }

    if (textileEnabled)
    {
    	vec3 textile_color = texture2D(textile, vertTexCoord.st).rgb;
	    rgb = rgb * textile_color;
	}

	gl_FragColor.rgb = rgb;
}

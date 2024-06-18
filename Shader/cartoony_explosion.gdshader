shader_type canvas_item;

#define iTime TIME
#define iResolution 1.0/SCREEN_PIXEL_SIZE
#define fragColor COLOR

uniform vec3 boom_pal1 = vec3(.2, .15, .3);
uniform vec3 boom_pal2 = vec3(.9, .15, .05);
uniform vec3 boom_pal3 = vec3(.9, .5, .1);
uniform vec3 boom_pal4 = vec3(.95, .95, .35);

uniform vec3 smoke_pal1 = vec3(.2, .15, .3);
uniform vec3 smoke_pal2 = vec3(.35, .3, .45);
uniform vec3 smoke_pal3 = vec3(.5, .45, .6);

uniform float size : hint_range(0.1, 50.0, 0.1) = 5.;
uniform float disperse : hint_range(0.1, 10.0, 0.1) = 1.;
uniform float boom_repeat : hint_range(0.0, 10.0, 0.1) = 1.;
uniform float boom_shape : hint_range(0.1, 20.0, 0.1) = 12.;
uniform float boom_distortion : hint_range(0.0, 10.0, 0.1) = .5;
uniform float boom_bubbles : hint_range(0.0, 10.0, 0.1) = .5;
uniform float boom_bw : hint_range(0.0, 10.0, 0.1) = .5;

uniform float smoke_repeat : hint_range(0.0, 10.0, 0.1) = 1.0;
uniform float smoke_shape : hint_range(0.0, 30.0, 0.1) = 16.0;
uniform float smoke_distortion : hint_range(0.0, 10.0, 0.1) = 1.5;
uniform float smoke_bubbles : hint_range(0.0, 10.0, 0.1) = 0.5;
uniform float smoke_bw : hint_range(0.0, 10.0, 0.1) = .75;

uniform vec2 disp = vec2(0.0);

vec3 n_rand3(vec3 p) {
    vec3 r =
        fract(
            sin(
                vec3(
                    dot(p, vec3(127.1,311.7,371.8)),
                    dot(p,vec3(269.5,183.3,456.1)),
                    dot(p,vec3(352.5,207.3,198.67))
                )
            ) * 43758.5453
        ) * 2.0 - 1.0;
    return normalize(vec3(r.x/cos(r.x), r.y/cos(r.y), r.z/cos(r.z)));
}

float noise(vec3 p) {

    vec3 fv = fract(p);
    vec3 nv = vec3(floor(p));

    vec3 u = fv*fv*fv*(fv*(fv*6.0-15.0)+10.0);

    return (
        mix(
            mix(
                mix(
                    dot( n_rand3( nv+vec3(0.0,0.0,0.0) ), fv-vec3(0.0,0.0,0.0)),
                    dot( n_rand3( nv+vec3(1.0,0.0,0.0) ), fv-vec3(1.0,0.0,0.0)),
                    u.x
                ),
                mix(
                    dot( n_rand3( nv+vec3(0.0,1.0,0.0) ), fv-vec3(0.0,1.0,0.0)),
                    dot( n_rand3( nv+vec3(1.0,1.0,0.0) ), fv-vec3(1.0,1.0,0.0)),
                    u.x
                ),
                u.y
            ),
            mix(
                mix(
                    dot( n_rand3( nv+vec3(0.0,0.0,1.0) ), fv-vec3(0.0,0.0,1.0)),
                    dot( n_rand3( nv+vec3(1.0,0.0,1.0) ), fv-vec3(1.0,0.0,1.0)),
                    u.x
                ),
                mix(
                    dot( n_rand3( nv+vec3(0.0,1.0,1.0) ), fv-vec3(0.0,1.0,1.0)),
                    dot( n_rand3( nv+vec3(1.0,1.0,1.0) ), fv-vec3(1.0,1.0,1.0)),
                    u.x
                ),
                u.y
            ),
            u.z
       )
  );
}

float worley(vec3 s)
{
    vec3 si = floor(s);
    vec3 sf = fract(s);

    float m_dist = 1.;

    for (int y= -1; y <= 1; y++) {
        for (int x= -1; x <= 1; x++) {
            for (int z= -1; z <= 1; z++) {
                vec3 neighbor = vec3(float(x),float(y), float(z));

                vec3 point = fract(n_rand3(si + neighbor));
                point = 0.5 + 0.5*sin(disperse * iTime + 6.2831*point);

                vec3 diff = neighbor + point - sf;

                float dist = length(diff);

                m_dist = min(m_dist, dist);
            }
        }
    }

    return m_dist;
}

float oct_noise(vec3 pos, float o)
{

    float ns = 0.0;
    float d = 0.0;

    int io = int(o);
    float fo = fract(o);

    for(int i=0;i<=io;++i)
    {
        float v = pow(2.0,float(i));
        d += 1.0/v;
        ns += noise(pos*v)*(1.0/v);
    }


    float v = pow(2.0,float(io+1));
    d+= 1.0*fo/v;
    ns += noise(pos*v)*(1.0*fo/v);

    return ns/d;
}

float boom (vec2 p)
{
    float repeat = mod(iTime * boom_repeat, 2.);
    float shape = 1.-pow(distance(vec3(p, 0.), vec3(0.)),2.) / (repeat*boom_shape) - repeat*2.;

    float distortion = noise(vec3(p*boom_distortion, iTime*.5));
    float bubbles = boom_bubbles-pow(worley(vec3(p*1.2,iTime*2.)), 3.);
    float bw = boom_bw;
    float effects = (bw * bubbles + (1.-bw) * distortion);

    return shape + effects;
}

float smoke (vec2 p)
{
    float repeat = mod(iTime * smoke_repeat, 2.);
    float shape = 1.-pow(distance(vec3(p - vec2(0, 2) * pow(repeat/1.45,2.)*1.5, 0.), vec3(0.)),2.) / (repeat* smoke_shape) - pow(repeat*1.5,.5);

    float distortion = noise(vec3(p*smoke_distortion - vec2(0, 2) * pow(repeat/1.45,2.)*1.5, iTime*.1));
    float bubbles = smoke_bubbles-pow(worley(vec3((p/pow(repeat,.35)) - vec2(0, 2) * pow(repeat/1.65,2.)*1.5, iTime*.1)), 2.);
    float bw = smoke_bw;
    float effects = (bw * bubbles + (1.-bw) * distortion);

    return shape + effects;
}

float f (vec2 p){
    float b = boom(p);
    float s = smoke(p);
    return b > s ? b : s;
}

vec2 grad( vec2 x )
{
    vec2 h = vec2( 0.01, 0.0 );
    return vec2( f(x+h.xy) - f(x-h.xy),
                 f(x+h.yx) - f(x-h.yx) )/(2.0*h.x);
}

float border (vec2 uv)
{

    float b = f( uv );
    vec2  g = grad( uv );
    float de = abs(b)/length(g);
    float eps = .01;

    return smoothstep( 1.0*eps, 2.0*eps, de );
}

float posterize(float v, int n)
{
    float fn = float(n);
    return floor(v*fn)/(fn-1.);
}

void fragment()
{
	vec3 boom_pal[4] = {
	 boom_pal1,
    boom_pal2,
    boom_pal3,
    boom_pal4
	};

vec3 smoke_pal[] =
    {smoke_pal1,
    smoke_pal2,
    smoke_pal3};

    vec2 uv = SCREEN_UV;
	uv.y = 1.0 -uv.y;
    vec2 pos = uv - vec2(.5, .4);
    pos.x /= SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
    pos *= 1. * size;
    pos = pos - disp;

    int bpl = boom_pal.length();
    int spl = smoke_pal.length();


    float boom_val = boom(pos);
    float boom_a = step(0., boom_val);
    vec3 boom_col = boom_pal[int(posterize(boom_val, bpl)*float(bpl))] - vec3(1.-boom_a);

    float smoke_val = smoke(pos);
    float smoke_a = step(0., smoke_val);
    vec3 smoke_col = smoke_pal[int(posterize(smoke_val, spl)*float(spl))] - vec3(1.-smoke_a);

    float b = step(1.,border(pos));

    float bw = step(smoke_val*1.25, boom_val);

    vec3 color = bw * boom_col + (1.-bw) * smoke_col;
    float alpha = bw * boom_a + (1.-bw) * smoke_a;

    vec4 result = vec4(alpha == 1. ? color : vec3(0.5), alpha) - vec4(vec3(1.-b), 1.);

    fragColor = vec4(result.rgb, alpha);
}

// Useful macro for time
#define time iTime
// Functions defining a circle, vertical line and horizontal line
float circle (vec2 p, float r)
{
	return length(p) - r;
}
float vline (vec2 p) 
{
	return abs(p.x);
}
float hline (vec2 p)
{
	return abs(p.y);
}
// Merge two objects (used for the circles)
vec2 merge(vec2 d1, vec2 d2) {
    return abs(d1).x<abs(d2.x) ? d1 : d2;
}
// Repeat function using fract
vec4 cRep4(vec2 p, float n) 
{
     vec2 pn = p * n;
     return vec4(fract(pn) * 2.0 - 1.0, floor(pn)+vec2(1.0));
}
//
float asLine(float d) {
    return smoothstep(.1,.0,abs(d));
}

float asDisc(float d) {
    return smoothstep(.2,.1,d);
}
// Do points of given cell
vec2 doCell(vec2 local, vec2 cellCoord, vec2 cellOffset) 
{
    vec2 l = local - cellOffset * 2.0; // adjusted local coords
    vec2 id = cellCoord + cellOffset; // cell coordinates/id
    float c = circle(l+vec2(sin(time*1.7+id.x*id.y*-.02)*id.y*.2, cos(time*1.7+id.x*id.y*-.02)*id.y*.2), .1);
    return vec2(c, id.x*id.y);
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // uv = Pixel normalised coordinates
	vec2 uv = (2.*fragCoord-iResolution.xy )/iResolution.y;
    // Lines to form divisions between panels
    float line1 = smoothstep(.01, .02, vline(uv));
    float line2 = smoothstep(.01, .02, hline(uv));
    
    //Checking which area the current pixel is in and running the appropriate code for that panel
    if (uv.x < 0. && uv.y < 0.) 
    {   
        // Bottom left panel
    	uv = uv + vec2(.9, .51);
    	
        // c1 is the large circle, c2 is the moving one
    	float c1 = smoothstep(.02, .001, abs(circle(uv, (.4))));
    	float c2 = smoothstep(.02, .01, circle(uv+vec2(sin(time*2.), cos(time*2.))*.4, (.05)));
        
        fragColor = vec4(vec3(c1+c2, .1, .1)*line1*line2, 1.0);
    }
    else if (uv.y > 0.)
    {	
        // Top panel
  
        float surface = 13.;                     
        vec4 cell = cRep4(uv, 15.);
        vec2 dist = vec2(100.0,0);
        // Looking at neighbouring and displaying dots leaking from other cells to prevent cutoff
        if(cell.w<surface-2.) {
            dist = merge(dist, doCell(cell.xy, cell.zw, vec2(-1,1)));
            dist = merge(dist, doCell(cell.xy, cell.zw, vec2(1,1)));
            dist = merge(dist, doCell(cell.xy, cell.zw, vec2(0,1)));
        }
        if(cell.w<surface-1.) {
            dist = merge(dist, doCell(cell.xy, cell.zw, vec2(0.0)));
            dist = merge(dist, doCell(cell.xy, cell.zw, vec2(1,0)));
            dist = merge(dist, doCell(cell.xy, cell.zw, vec2(-1,0)));
        }
        if(cell.w<surface) {
        	dist = merge(dist, doCell(cell.xy, cell.zw, vec2(1,-1)));
        	dist = merge(dist, doCell(cell.xy, cell.zw, vec2(-1,-1)));
        	dist = merge(dist, doCell(cell.xy, cell.zw, vec2(0,-1)));
        }
            
        
        fragColor = vec4(vec3(asDisc(dist.x), .1, .1), 1.);//vec4(vec3(c3, .1, .1)*line2, 1.0);
    }
    else
    { 	
        // Bottom right panel
     	// Defining the plane waves, i.e. lines
     	float planewave = sin(uv.x*30.+iTime*10.)*.7+.3;
    
    	fragColor = vec4(planewave*.7, .1, .1, 1.)*line2*line1;       
    }
}
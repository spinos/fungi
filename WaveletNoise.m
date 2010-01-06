//
//  WaveletNoise.m
//  triangle
//
//  Created by jian zhang on 1/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WaveletNoise.h"

#import "zmath.h"
#import "perlin.h"

@implementation WaveletNoise
- (id) init
{
	[super init];
	
	name = @"WaveletNoise";
	
	poolw = poolh = 128;
	glInited = 0;
	
	vert_source =

@"uniform float Frequency;"

"varying vec3  TexCoord;"

"void main(void)"
"{"
"    TexCoord        = (gl_MultiTexCoord0.xyz + vec3(-31.792, -19.133, 23.467))*Frequency;"
"    gl_Position     = ftransform();"
"}";

	frag_source =
@"uniform sampler2D WhiteNoise;"
"uniform float Lacunarity;"
"uniform float Dimension;"

"varying vec3  TexCoord;"

"float fractal_func(vec2 pcoord)"
"{"
"	float f=1.0;"
"	float fractal = texture2D(WhiteNoise, pcoord).r*0.5 + 0.5;" 

"	f*= Lacunarity;"

"	fractal += texture2D(WhiteNoise, pcoord*f).r/pow(f, Dimension);" 


"	f*= Lacunarity;"

"	fractal += texture2D(WhiteNoise, pcoord*f).r/pow(f, Dimension);" 

"	f*= Lacunarity;"

"	fractal += texture2D(WhiteNoise, pcoord*f).r/pow(f, Dimension);" 

"	f*= Lacunarity;"

"	fractal += texture2D(WhiteNoise, pcoord*f).r/pow(f, Dimension);" 
"return clamp(fractal,0.0, 1.0);"
"}"

"void main (void)"
"{" 
"	float s = fractal_func(TexCoord.xy);"
"    gl_FragColor = vec4 (s, s, s,  1.0);"
"}";

	FloatAttr *lacunarity = [[FloatAttr alloc] init];
	lacunarity.modelName =@"Lacunarity";
	lacunarity.val = 2.0;
	lacunarity.min = 1.0;
	lacunarity.max = 4.0;
	FloatAttr *dimension = [[FloatAttr alloc] init];
	dimension.modelName =@"Dimension";
	dimension.val = 1.0;
	dimension.min = 0.0;
	dimension.max = 3.0;
	FloatAttr *freq = [[FloatAttr alloc] init];
	freq.modelName =@"Frequency";
	freq.val = 1.0;
	freq.min = 0.1;
	freq.max = 4.0;
	
	float_attr_array = [NSArray arrayWithObjects:
	lacunarity,
	dimension,
	freq,
	nil];
	
	[float_attr_array retain];

	return self;
}

- (void) draw
{
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, texname);
	glUseProgram(program);
	[self updateUniformFloat];
	glBegin(GL_QUADS);
	glMultiTexCoord3f(GL_TEXTURE0, 0, 0, 0);
	glVertex3f(-1, -1, 0);
	glMultiTexCoord3f(GL_TEXTURE0, 1, 0, 0);
	glVertex3f(1, -1, 0);
	glMultiTexCoord3f(GL_TEXTURE0, 1, 1, 0);
	glVertex3f(1, 1, 0);
	glMultiTexCoord3f(GL_TEXTURE0, 0, 1, 0);
	glVertex3f(-1, 1, 0);
	glEnd();
	glUseProgram(0);
}

- (void) initGL
{
	float *texels = malloc(poolw*poolh*sizeof(float));
	int u, v;
	//srand(20757);
	double ni[3];
	double inci, incj, inck;
	ni[0] = ni[1] = ni[2] = 0;
	SetNoiseFrequency(64);
	
	inck = 1.0/2.0; incj = 1.0/2.0; inci = 1.0/2.0;
	ni[0] += inck;
	for(v=0; v<poolh; v++) {
		ni[1] += incj;
		for(u=0; u<poolw; u++) {
			ni[2] += inci;
			//texels[v*poolw+u] = (float)(rand()%901)/901.f;
			texels[v*poolw+u] = noise3(ni);
		}
	}
	
	glGenTextures(1, &texname);	
	glBindTexture(GL_TEXTURE_2D, texname);	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

	//glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE32F_ARB, poolw, poolh, 0, GL_LUMINANCE, GL_FLOAT, texels);
	
	int w = poolw, h = poolh;
	
	float *down_pix = malloc(w/2*h/2*sizeof(float));
	
		for(v=0; v<h/2; v++) {
			for(u=0; u<w/2; u++) {
				down_pix[v*w/2+u] = downSample2D(u, v, w, h, texels);
			}
		}
	
	float *up_pix = malloc(w*h*sizeof(float));
	
		for(v=0; v<h; v++) {
			for(u=0; u<w; u++) {
				up_pix[v*w+u] = upSample2D(u, v, w/2, h/2, down_pix);
			}
		}
	
	for(v=0; v<poolh; v++) {
		for(u=0; u<poolw; u++) {
			texels[v*poolw+u] = texels[v*poolw+u] - up_pix[v*poolw+u];
		}
	}
	
	glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE16F_ARB, w, h, 0, GL_LUMINANCE, GL_FLOAT, texels);
	
	free(up_pix);
	free(down_pix);
	free(texels);
	
	[self initShaders];
	[self uniformParam];
	
	glInited = 1;
}

- (void)uniformParam
{
/* Setup uniforms */
		glUseProgram(program);
		glUniform1i(glGetUniformLocation(program, "WhiteNoise"), 0);
		glUniform1f(glGetUniformLocation(program, "Lacunarity"), 2.0);
		glUniform1f(glGetUniformLocation(program, "Dimension"), 1.0);
		glUniform1f(glGetUniformLocation(program, "Frequency"), 32.0);
		glUseProgram(0);
}
@end

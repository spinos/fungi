//
//  PerlinNoise.m
//  triangle
//
//  Created by jian zhang on 1/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PerlinNoise.h"

#import "zmath.h"
#import "perlin.h"

@implementation PerlinNoise
- (id) init
{
	[super init];
	
	name = @"PerlinNoise";

	glInited = 0;

	return self;
}

- (void) draw
{
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, texname);
	
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
}

- (void) initGL
{
	float *texels = malloc(128*128*sizeof(float));
	
	double ni[3];
	double inci, incj, inck;
	ni[0] = ni[1] = ni[2] = 0;
	SetNoiseFrequency(64);
	int u, v;
	
	inck = 1.0/2.0; incj = 1.0/2.0; inci = 1.0/2.0;
	ni[0] += inck;
	for(v=0; v<128; v++) {
		ni[1] += incj;
		for(u=0; u<128; u++) {
			ni[2] += inci;
			texels[v*128+u] = (noise3(ni) + 1.0)*0.5;
		}
	}
	
	glGenTextures(1, &texname);	
	glBindTexture(GL_TEXTURE_2D, texname);	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

	glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE32F_ARB, 128, 128, 0, GL_LUMINANCE, GL_FLOAT, texels);
	
	free(texels);
	
	glInited = 1;
}

@end

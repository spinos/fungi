//
//  DownUpSample.m
//  triangle
//
//  Created by jian zhang on 1/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DownUpSample.h"
#import "zmath.h"

@implementation DownUpSample
- (id) init
{
	[super init];
	name = @"DownUpSample";
	
	glInited = 0;

	return self;
}

- (void) draw
{
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
	
	glBindTexture(GL_TEXTURE_2D, downname);
	glTranslatef(2.01,0,0);
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
	
	glBindTexture(GL_TEXTURE_2D, upname);
	glTranslatef(2.01,0,0);
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
	int w, h, u, v;
	checkEXRDim("/Users/jianzhang/Pictures/mrap128.exr", &w, &h);
	float *texels = malloc(w*h*sizeof(float));
	readEXRRED("/Users/jianzhang/Pictures/mrap128.exr", w,h, texels);

	glGenTextures(1, &texname);	
	glBindTexture(GL_TEXTURE_2D, texname);	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

	glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE32F_ARB, w, h, 0, GL_LUMINANCE, GL_FLOAT, texels);
	
	
	float *down_pix = malloc(w/2*h/2*sizeof(float));
	
		for(v=0; v<h/2; v++) {
			for(u=0; u<w/2; u++) {
				down_pix[v*w/2+u] = downSample2D(u, v, w, h, texels);
			}
		}
	
	glGenTextures(1, &downname);	
	glBindTexture(GL_TEXTURE_2D, downname);	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

	glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE32F_ARB, w/2, h/2, 0, GL_LUMINANCE, GL_FLOAT, down_pix);
	
	float *up_pix = malloc(w*h*sizeof(float));
	
		for(v=0; v<h; v++) {
			for(u=0; u<w; u++) {
				up_pix[v*w+u] = upSample2D(u, v, w/2, h/2, down_pix);
			}
		}
	
	glGenTextures(1, &upname);	
	glBindTexture(GL_TEXTURE_2D, upname);	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

	glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE32F_ARB, w, h, 0, GL_LUMINANCE, GL_FLOAT, up_pix);
	
	free(up_pix);
	free(down_pix);
	free(texels);
	
	glInited = 1;
}

@end

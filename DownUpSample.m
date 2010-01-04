//
//  DownUpSample.m
//  triangle
//
//  Created by jian zhang on 1/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DownUpSample.h"


@implementation DownUpSample
- (id) init
{
	[super init];
	modelName = @"DownUpSample";
	
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
}

- (void) initGL
{
	int w, h, u, v;
	checkEXRDim("/Users/jianzhang/Desktop/tomcat.exr", &w, &h);
	float *texels = malloc(w*h*sizeof(float));
	readEXRRED("/Users/jianzhang/Desktop/tomcat.exr", w,h, texels);
	
	
	glGenTextures(1, &texname);	
	glBindTexture(GL_TEXTURE_2D, texname);	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

	glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE32F_ARB, w, h, 0, GL_LUMINANCE, GL_FLOAT, texels);
	
	free(texels);
	
	glInited = 1;
}

@end

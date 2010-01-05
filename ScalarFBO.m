//
//  ScalarFBO.m
//  triangle
//
//  Created by jian zhang on 1/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ScalarFBO.h"


@implementation ScalarFBO
- (id) init
{
	[super init];
	name = @"ScalarFBO";
	
	glInited = 0;

	return self;
}

- (void)preflight
{
	glPushAttrib(GL_ALL_ATTRIB_BITS);
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, cfbo);
	glViewport(0,0,512, 512);
	glDrawBuffer(GL_COLOR_ATTACHMENT0_EXT);
	glClearColor(0,0,0,0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();	
	glOrtho(-1.0, 1.0, -1.0, 1.0, 1.0, 100.0);
	glMatrixMode(GL_MODELVIEW);
	
	glLoadIdentity();
		gluLookAt(0,0,4,
				  0,0,0,
				  0,1,0);
				  
	glDisable(GL_TEXTURE_2D);
glColor3f(1,1,1);
	glBegin(GL_TRIANGLES);
		glVertex3f(-1,-1,1);
		glVertex3f(1,-1,1);
		glVertex3f(0,1,1);
	glEnd();
	
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
	glPopAttrib();
}

- (void) draw
{
glColor3f(1,1,1);
glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, ctexname);
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
	glGenFramebuffersEXT(1, &cfbo);
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, cfbo);
	
	float *texels = malloc(512*512*sizeof(float));
	int u, v;
	
	for(v=0; v<512; v++) {
		for(u=0; u<512; u++) {
			texels[(v*512+u)] = (float)(random()%1931)/1931.f;
			//texels[(v*512+u)*3+1] = 1;
			//texels[(v*512+u)*3+2] = 0;
			//texels[(v*512+u)*4+3] = 1;
		}
	}
	
	glGenTextures(1, &ctexname);	
	glBindTexture(GL_TEXTURE_2D, ctexname);	
	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA16F_ARB, 512, 512, 0, GL_RED, GL_FLOAT, texels);
	
	free(texels);
	
	glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, ctexname, 0);
	
	 GLenum status;                                           
        status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);
        if(status !=  GL_FRAMEBUFFER_COMPLETE_EXT ) NSLog(@"failed fbo");
		
	glGenTextures(1, &stexname);	
	glBindTexture(GL_TEXTURE_2D, stexname);	
	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA16F_ARB, 512, 512, 0, GL_RGBA, GL_FLOAT, 0);
	
	glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT1_EXT, GL_TEXTURE_2D, stexname, 0);
	
	                                          
        status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);
        if(status !=  GL_FRAMEBUFFER_COMPLETE_EXT ) NSLog(@"failed fbo");
		  
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
	
	glInited = 1;
}

@end

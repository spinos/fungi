//
//  RayMarch.m
//  triangle
//
//  Created by jian zhang on 1/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RayMarch.h"


@implementation RayMarch
- (id) init
{
	[super init];
	name = @"RayMarch";
	
	glInited = 0;
	
	vert_source =

@"varying vec3  RayVec;"
"varying vec3  RayOrigin;"

"void main(void)"
"{"
"	vec3 eye = vec3(0.0,0.0,4.0);"
"    RayVec        = gl_MultiTexCoord0.xyz - eye;"
"    RayVec        = normalize(RayVec);"
"	RayOrigin = gl_MultiTexCoord0.xyz;"
"    gl_Position     = ftransform();"
"}";

	frag_source =
@"uniform sampler2D WhiteNoise;"

"varying vec3  RayVec;"
"varying vec3  RayOrigin;"

"vec2 ray_box_hit()"
"{"
"float T1, T2, Tmp;"
"float epsilon = 10e-8;"
"float Tnear = -10e8;"
"float Tfar = 10e8;"
"T1 = (-1.0 - RayOrigin.x)/(RayVec.x + epsilon);"
"T2 = (1.0 - RayOrigin.x)/(RayVec.x + epsilon);"

"if(T1 > T2)" 
"	{"
"	Tmp=T1;"
"	T1=T2;"
"	T2=Tmp;"
"	}"	
"	if(T1>Tnear) Tnear = T1;"
"	if(T2<Tfar) Tfar = T2;"
		
"	if(Tfar<0.0 || Tnear>Tfar) return vec2(0.0);"


"T1 = (-1.0 - RayOrigin.y)/(RayVec.y + epsilon);"
"T2 = (1.0 - RayOrigin.y)/(RayVec.y + epsilon);"

"if(T1 > T2) "
"{"
"	Tmp=T1;"
"	T1=T2;"
"	T2=Tmp;"
"}"	
"	if(T1>Tnear) Tnear = T1;"
"	if(T2<Tfar) Tfar = T2;"
		
"	if(Tfar<0.0 || Tnear>Tfar) return vec2(0.0);"


"T1 = (-1.0 - RayOrigin.z)/(RayVec.z + epsilon);"
"T2 = (1.0 - RayOrigin.z)/(RayVec.z + epsilon);"

"if(T1 > T2)" 
"{"
"	Tmp=T1;"
"	T1=T2;"
"	T2=Tmp;"
"}"	
"	if(T1>Tnear) Tnear = T1;"
"	if(T2<Tfar) Tfar = T2;"
		
"	if(Tfar<0.0 || Tnear>Tfar) return vec2(0.0);"
"if(Tnear < 0.01) Tnear = 0.01;"
"return vec2(Tnear, Tfar);"
"}"

"void main (void)"
"{" 
" vec2 hit = ray_box_hit();"
" float num_step = 0.0;"
"if(hit.x > 0.01) num_step = (hit.y - hit.x)/0.033;"

"float m = 0.0;"
"float i, step_size;"
"for(i=0.0; i < num_step; i++) {"
"	step_size = num_step - i;"
"	if(step_size > 1.0) step_size = 1.0;"
"	m += 0.05 * step_size;"
"}"
"    gl_FragColor = vec4 (m,m,m,  1.0);"

"}";

	return self;
}

- (void)preflight
{
	glPushAttrib(GL_ALL_ATTRIB_BITS);
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, ifbo);
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
	glUseProgram(program);
	glBegin(GL_QUADS);
		glMultiTexCoord3f(GL_TEXTURE0_ARB, -1,-1,2);
		glVertex3f(-1,-1,1);
		glMultiTexCoord3f(GL_TEXTURE0_ARB, 1,-1,2);
		glVertex3f(1,-1,1);
		glMultiTexCoord3f(GL_TEXTURE0_ARB, 1,1,2);
		glVertex3f(1,1,1);
		glMultiTexCoord3f(GL_TEXTURE0_ARB, -1,1,2);
		glVertex3f(-1,1,1);
	glEnd();
	glUseProgram(0);
	
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
	glPopAttrib();
}

- (void) draw
{
glColor3f(1,1,1);
glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, itex);
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
	glGenFramebuffersEXT(1, &ifbo);
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, ifbo);
	
	glGenTextures(1, &itex);	
	glBindTexture(GL_TEXTURE_2D, itex);	
	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA16F_ARB, 512, 512, 0, GL_RED, GL_FLOAT, 0);
	
	
	glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, itex, 0);
	
	 GLenum status;                                           
        status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);
        if(status !=  GL_FRAMEBUFFER_COMPLETE_EXT ) NSLog(@"failed fbo");

	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
	
	[self initShaders];
	
	glInited = 1;
}

@end

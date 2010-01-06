//
//  RenderTo3DTex.m
//  triangle
//
//  Created by jian zhang on 1/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RenderTo3DTex.h"
#import "zmath.h"
#import "perlin.h"

@implementation RenderTo3DTex
- (id) init
{
	[super init];
	name = @"RenderTo3DTex";
	
	glInited = 0;
	
	vert_source =

@"varying vec3  RayVec;"
"varying vec3  RayOrigin;"

"void main(void)"
"{"
"	vec3 eye = vec3(4.0,0.0,4.0);"
"    RayVec        = gl_MultiTexCoord0.xyz - eye;"
"    RayVec        = normalize(RayVec);"
"	RayOrigin = gl_MultiTexCoord0.xyz;"
"    gl_Position     = ftransform();"
"}";

	frag_source =
@"uniform sampler3D DensityUnit;"

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
"if(hit.x > 0.01) num_step = (hit.y - hit.x)/0.02;"

"vec3 m = vec3(0.0);"
"float i, step_size, ray_length, weight;"
"vec3 sp;"
"vec4 vol;"
"float acc_dens= 0.0;"
"float dif_dens;"
"for(i=0.0; i < num_step; i++) {"
"	step_size = num_step - i;"
"	if(step_size > 1.0) step_size = 1.0;"

"	ray_length = hit.x + i * 0.02;"
"	sp = RayOrigin + RayVec * ray_length;"

"	sp = sp*0.5 + vec3(0.5);"

"	vol = texture3D(DensityUnit, sp);"

"weight = 1.0 * vol.a * step_size;"

"dif_dens = (1.0 - acc_dens) * weight;"
"	acc_dens += dif_dens;"

"	 m = m + (vol.xyz - m) * dif_dens;"

"	if(acc_dens >= 1.0) i = num_step+2.0;"


"}"
"    gl_FragColor = vec4 (m,  1.0);"
//"    gl_FragColor = vec4 (vec3(acc_dens),  1.0);"

"}";

	return self;
}

- (void)preflight
{
// draw to 3d tex first
	glPushAttrib(GL_ALL_ATTRIB_BITS);
	glClearColor(0,0,0,0);
	glDisable(GL_DEPTH_TEST);
	
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, volfbo);
	glViewport(0,0,40, 40);
	glDrawBuffer(GL_COLOR_ATTACHMENT0_EXT);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

				  
	glDisable(GL_TEXTURE_2D);
	int z;
	float slice;
	for(z=0; z<40; z++) {
	
        // attach texture slice to FBO
        glFramebufferTexture3DEXT( GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT,
                               GL_TEXTURE_3D, tgvoltex, 0, z );
							   glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
				
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();	
	glOrtho(-1, 1, -1, 1, 0.1, 0.125);
	glMatrixMode(GL_MODELVIEW);
	
	glLoadIdentity();
		gluLookAt(0,0,0.125 + z*0.025,
				  0,0,0,
				  0,1,0);
		
		slice = (float)(z) / 40.f;
        // draw point
		
		glColor4f(0,1, slice, 1.0);
		glBegin(GL_POINTS);
		
		
			
			
			glVertex3f( 0.1, 0.1, 0.65);
			glVertex3f( 0.125, 0.1, 0.65);
			glVertex3f( 0.15, 0.1, 0.65);
			glVertex3f( 0.15, 0.125, 0.65);
			glVertex3f( 0.15, 0.15, 0.65);
			glVertex3f( 0.15, 0.175, 0.65);
			glVertex3f( 0.15, 0.2, 0.65);
			glVertex3f( 0.15, 0.225, 0.65);
			glVertex3f( 0.15, 0.25, 0.65);
			glVertex3f( 0.175, 0.25, 0.65);
			glVertex3f( 0.2, 0.25, 0.65);
			glVertex3f( 0.225, 0.25, 0.65);
			glVertex3f( 0.225, 0.25, 0.625);
			glVertex3f( 0.225, 0.25, 0.6);
			glVertex3f( 0.225, 0.275, 0.6);
			glVertex3f( 0.225, 0.3, 0.6);
			glVertex3f( 0.225, 0.325, 0.575);
			glVertex3f( 0.225, 0.35, 0.55);
			glVertex3f( 0.225, 0.35, 0.525);
			glVertex3f( 0.225, 0.325, 0.5);
			glVertex3f( 0.225, 0.3, 0.475);
			glVertex3f( 0.225, 0.275, 0.475);
			glVertex3f( 0.225, 0.25, 0.475);
			glVertex3f( 0.225, 0.225, 0.475);
			glVertex3f( 0.225, 0.2, 0.475);
			glVertex3f( 0.225, 0.175, 0.475);
			glVertex3f( 0.225, 0.175, 0.45);
			glVertex3f( 0.225, 0.175, 0.425);
			glVertex3f( 0.225, 0.15, 0.425);
			glVertex3f( 0.225, 0.125, 0.425);
			glVertex3f( 0.225, 0.1, 0.425);
			glVertex3f( 0.2, 0.1, 0.425);
			glVertex3f( 0.175, 0.075, 0.425);
			glVertex3f( 0.15, 0.075, 0.425);
			glVertex3f( 0.125, 0.05, 0.425);
			glVertex3f( 0.1, 0.05, 0.425);

		glEnd();
    }
	
	
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
	
// draw render buffer	
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, ifbo);
	glViewport(0,0,512, 512);
	glDrawBuffer(GL_COLOR_ATTACHMENT0_EXT);
	
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
	//glEnable(GL_TEXTURE_3D);
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_3D, tgvoltex);
glColor3f(1,1,1);
	glUseProgram(program);
	glBegin(GL_QUADS);
		glMultiTexCoord3f(GL_TEXTURE0_ARB, 1,-1,3);
		glVertex3f(-1,-1,1);
		glMultiTexCoord3f(GL_TEXTURE0_ARB, 3,-1,1);
		glVertex3f(1,-1,1);
		glMultiTexCoord3f(GL_TEXTURE0_ARB, 3,1,1);
		glVertex3f(1,1,1);
		glMultiTexCoord3f(GL_TEXTURE0_ARB, 1,1,3);
		glVertex3f(-1,1,1);
	glEnd();
	glUseProgram(0);
	//glDisable(GL_TEXTURE_3D);
	glEnable(GL_TEXTURE_2D);
	
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
	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA16F_ARB, 512, 512, 0, GL_RED, GL_FLOAT, 0);
	
	
	glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, itex, 0);
	
	 GLenum status;                                           
        status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);
        if(status !=  GL_FRAMEBUFFER_COMPLETE_EXT ) NSLog(@"failed fbo");

	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
	

	
int DENSITY_WIDTH = 40;
int DENSITY_HEIGHT = 40;
int DENSITY_DEPTH = 40;

	glGenFramebuffersEXT(1, &volfbo);
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, volfbo);
	
	// 3d texture
	glGenTextures(1, &tgvoltex);	
	glBindTexture(GL_TEXTURE_3D, tgvoltex);	
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER);
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER);
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_BORDER);
	
	float *texels = malloc( DENSITY_WIDTH * DENSITY_HEIGHT * DENSITY_DEPTH * 4 * sizeof(float));
	int u, v, w;
	for(w=0; w< DENSITY_DEPTH; w++) {
		for(v=0; v< DENSITY_HEIGHT; v++) {
			for(u=0; u< DENSITY_WIDTH; u++) {
				texels[(w*( DENSITY_WIDTH * DENSITY_HEIGHT)+v * DENSITY_WIDTH + u)*4] = 0.f;
				texels[(w*( DENSITY_WIDTH * DENSITY_HEIGHT)+v * DENSITY_WIDTH + u)*4+1] = 0.f;
				texels[(w*( DENSITY_WIDTH * DENSITY_HEIGHT)+v * DENSITY_WIDTH + u)*4+2] = 0.f;
				texels[(w*( DENSITY_WIDTH * DENSITY_HEIGHT)+v * DENSITY_WIDTH + u)*4+3] = 0.f;
			}
		}
	}
	
	glTexImage3D(GL_TEXTURE_3D, 0, GL_RGBA32F_ARB, DENSITY_WIDTH, DENSITY_HEIGHT, DENSITY_DEPTH, 0, GL_RGBA, GL_FLOAT, texels);
	
	free(texels);
	
	glFramebufferTexture3DEXT( GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT,
                               GL_TEXTURE_3D, tgvoltex, 0, 0 );
							   
	 status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);
        if(status !=  GL_FRAMEBUFFER_COMPLETE_EXT ) NSLog(@"failed fbo 3d");
	
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
	
	[self initShaders];
	
	glUseProgram(program);
		glUniform1i(glGetUniformLocation(program, "DensityUnit"), 0);
		glUseProgram(0);
	
	glInited = 1;
}

@end

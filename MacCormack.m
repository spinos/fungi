//
//  WaveletNoise.m
//  triangle
//
//  Created by jian zhang on 1/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MacCormack.h"

#import "zmath.h"
#import "perlin.h"


@implementation MacCormack
- (id) init
{
	[super init];
	
	name = @"MacCormack";
	
	glInited = 0;
	
	vert_source =

@"uniform float Frequency;"

"varying vec3  TexCoord;"
"varying vec3  NoiCoord;"

"void main(void)"
"{"
"    NoiCoord        = (gl_MultiTexCoord0.xyz+vec3(0.21,0.32,0.74))*Frequency;"
"    TexCoord        = gl_MultiTexCoord0.xyz;"

"    gl_Position     = ftransform();"
"}";

	frag_source =
@"uniform sampler3D WhiteNoise;"
"uniform sampler2D DensityUnit;"
"uniform sampler2D VelocityUnit;"
"uniform float Lacunarity;"
"uniform float Dimension;"

"uniform float item;"

"varying vec3  TexCoord;"
"varying vec3  NoiCoord;"


"float fractal_func(vec3 pcoord)"
"{"
"	float f=1.0;"
"	float amplitude = 1.0;"
"	float fractal = texture3D(WhiteNoise, pcoord).r*0.5+0.5;" 


"	f*= Lacunarity;"
"	amplitude *= 0.56123;"
"	fractal += texture3D(WhiteNoise, pcoord*f).r * amplitude;" 


"	f*= Lacunarity;"
"	amplitude *= 0.56123;"
"	fractal += texture3D(WhiteNoise, pcoord*f).r * amplitude;" 



"	f*= Lacunarity;"
"	amplitude *= 0.56123;"
"	fractal += texture3D(WhiteNoise, pcoord*f).r * amplitude;" 


/*
"	f*= Lacunarity;"
"	amplitude *= 0.56123;"
"	fractal += texture3D(WhiteNoise, pcoord*f).r * amplitude;"*/
"return clamp(fractal,0.0, 1.0);"
"}"

"vec2 ForwardAdvect(vec2 cell, vec2 u)"
"{"
"vec2 fwdcell = cell.xy - u/64.0 *0.0;"
"return texture2D(VelocityUnit, fwdcell).xy;"
"}"

"void main (void)"
"{" 
"	vec2 x = TexCoord.xy;"
"	vec2 u = texture2D(VelocityUnit, x).xy;" 
"	vec2 adv = ForwardAdvect(x, u);"

"    gl_FragColor = vec4 (adv, 0.0, 1.0);"
"    gl_FragColor = vec4 (1.0, 1.0, 0.0, 1.0);"
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
	freq.val = 0.5;
	freq.min = 0.001;
	freq.max = 1.0;
	
	float_attr_array = [NSArray arrayWithObjects:
	lacunarity,
	dimension,
	freq,
	nil];
	
	[float_attr_array retain];

	return self;
}

- (void)preflight
{
	glPushAttrib(GL_ALL_ATTRIB_BITS);
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, buffbo);
	
	glViewport(0,0, srcw, srch);
	
// advecting velocity by velocity, write to buf
	glDrawBuffer(GL_COLOR_ATTACHMENT1_EXT);
	glClearColor(0,0,0,0);
	glClear(GL_COLOR_BUFFER_BIT);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();	
	glOrtho(-1.0, 1.0, -1.0, 1.0, 1.0, 100.0);
	glMatrixMode(GL_MODELVIEW);
	
	glLoadIdentity();
		gluLookAt(0,0,4,
				  0,0,0,
				  0,1,0);
			  
	
glColor3f(1,1,1);

	glUseProgram(program);
	glUniform1f(glGetUniformLocation(program, "Dir"), -1);
	glUniform1f(glGetUniformLocation(program, "Conserve"), 0.99);
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, ivel);
	glActiveTexture(GL_TEXTURE1);
	glBindTexture(GL_TEXTURE_2D, ivel);
	
	
	glBegin(GL_QUADS);
		glMultiTexCoord3f(GL_TEXTURE0, 0, 0, 0.5); glVertex3f(-1,-1,0);
		glMultiTexCoord3f(GL_TEXTURE0, 1, 0, 0.5); glVertex3f(1,-1,0);
		glMultiTexCoord3f(GL_TEXTURE0, 1, 1, 0.5); glVertex3f(1,1,0);
		glMultiTexCoord3f(GL_TEXTURE0, 0, 1, 0.5); glVertex3f(-1,1,0);
	glEnd();
	
/*
// maccormack write to buf
	glDrawBuffer(GL_COLOR_ATTACHMENT1_EXT);
	
	glUseProgram(prog_maccormack);
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, ivel);
	glActiveTexture(GL_TEXTURE1);
	glBindTexture(GL_TEXTURE_2D, forward);
	glActiveTexture(GL_TEXTURE1);
	glBindTexture(GL_TEXTURE_2D, ivel);
	
	glBegin(GL_QUADS);
		glMultiTexCoord3f(GL_TEXTURE0, 0, 0, 0.5); glVertex3f(-1,-1,0);
		glMultiTexCoord3f(GL_TEXTURE0, 1, 0, 0.5); glVertex3f(1,-1,0);
		glMultiTexCoord3f(GL_TEXTURE0, 1, 1, 0.5); glVertex3f(1,1,0);
		glMultiTexCoord3f(GL_TEXTURE0, 0, 1, 0.5); glVertex3f(-1,1,0);
	glEnd();*/
	

glDrawBuffer(GL_COLOR_ATTACHMENT0_EXT);		
		
		glUseProgram(prog_add);
 glActiveTexture(GL_TEXTURE0);
	 glBindTexture(GL_TEXTURE_2D, bufvel);
	 glActiveTexture(GL_TEXTURE1);
	 glBindTexture(GL_TEXTURE_2D, iink);
	glBegin(GL_QUADS);
		glMultiTexCoord3f(GL_TEXTURE0, 0, 0, 0.5); glVertex3f(-1,-1,0);
		glMultiTexCoord3f(GL_TEXTURE0, 1, 0, 0.5); glVertex3f(1,-1,0);
		glMultiTexCoord3f(GL_TEXTURE0, 1, 1, 0.5); glVertex3f(1,1,0);
		glMultiTexCoord3f(GL_TEXTURE0, 0, 1, 0.5); glVertex3f(-1,1,0);
	glEnd();	
	
// record vorticity
glDrawBuffer(GL_COLOR_ATTACHMENT5_EXT);	
		
						glUseProgram(prog_vorticity);
						glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, ivel);
	glBegin(GL_QUADS);
		glMultiTexCoord3f(GL_TEXTURE0, 0, 0, 0.5); glVertex3f(-1,-1,0);
		glMultiTexCoord3f(GL_TEXTURE0, 1, 0, 0.5); glVertex3f(1,-1,0);
		glMultiTexCoord3f(GL_TEXTURE0, 1, 1, 0.5); glVertex3f(1,1,0);
		glMultiTexCoord3f(GL_TEXTURE0, 0, 1, 0.5); glVertex3f(-1,1,0);
	glEnd();
	
// recorde divergence
	glDrawBuffer(GL_COLOR_ATTACHMENT6_EXT);	
		
						glUseProgram(prog_divergence);
						glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, ivel);
	glBegin(GL_QUADS);
		glMultiTexCoord3f(GL_TEXTURE0, 0, 0, 0.5); glVertex3f(-1,-1,0);
		glMultiTexCoord3f(GL_TEXTURE0, 1, 0, 0.5); glVertex3f(1,-1,0);
		glMultiTexCoord3f(GL_TEXTURE0, 1, 1, 0.5); glVertex3f(1,1,0);
		glMultiTexCoord3f(GL_TEXTURE0, 0, 1, 0.5); glVertex3f(-1,1,0);
	glEnd();
// jacobi
	//glDrawBuffer(GL_COLOR_ATTACHMENT1_EXT);
// clear buf
	//glClear(GL_COLOR_BUFFER_BIT);
	glDrawBuffer(GL_COLOR_ATTACHMENT7_EXT);
// clear pressure
	glClear(GL_COLOR_BUFFER_BIT);
	
	int i;
	glUseProgram(prog_jacobi);
	for(i=0; i<30; i++) {
	//if(i%2 == 0) glDrawBuffer(GL_COLOR_ATTACHMENT1_EXT);
	//else 
	glDrawBuffer(GL_COLOR_ATTACHMENT7_EXT);
	
		
		glActiveTexture(GL_TEXTURE0);
		
		//if(i%2 == 0) 
		glBindTexture(GL_TEXTURE_2D, ipressure);
		//else glBindTexture(GL_TEXTURE_2D, bufvel);
		
		glActiveTexture(GL_TEXTURE1);
		glBindTexture(GL_TEXTURE_2D, idivergence);
		glBegin(GL_QUADS);
			glMultiTexCoord3f(GL_TEXTURE0, 0, 0, 0.5); glVertex3f(-1,-1,0);
			glMultiTexCoord3f(GL_TEXTURE0, 1, 0, 0.5); glVertex3f(1,-1,0);
			glMultiTexCoord3f(GL_TEXTURE0, 1, 1, 0.5); glVertex3f(1,1,0);
			glMultiTexCoord3f(GL_TEXTURE0, 0, 1, 0.5); glVertex3f(-1,1,0);
		glEnd();
	
	}

// pressure gradient
	glDrawBuffer(GL_COLOR_ATTACHMENT1_EXT);
	glUseProgram(prog_gradient);
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, ivel);
	glActiveTexture(GL_TEXTURE1);
	glBindTexture(GL_TEXTURE_2D, ipressure);
	glBegin(GL_QUADS);
		glMultiTexCoord3f(GL_TEXTURE0, 0, 0, 0.5); glVertex3f(-1,-1,0);
		glMultiTexCoord3f(GL_TEXTURE0, 1, 0, 0.5); glVertex3f(1,-1,0);
		glMultiTexCoord3f(GL_TEXTURE0, 1, 1, 0.5); glVertex3f(1,1,0);
		glMultiTexCoord3f(GL_TEXTURE0, 0, 1, 0.5); glVertex3f(-1,1,0);
	glEnd();
	
	glReadBuffer(GL_COLOR_ATTACHMENT1_EXT);
	float *texels = malloc(srcw*srch*3*sizeof(float));
glReadPixels( 0, 0,  srcw, srch, GL_RGB, GL_FLOAT, texels);
glBindTexture(GL_TEXTURE_2D, ivel);	
glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB16F_ARB, srcw, srch, 0, GL_RGB, GL_FLOAT, texels);


	

glDrawBuffer(GL_COLOR_ATTACHMENT1_EXT);	
		
						glUseProgram(prog_swirl);
						glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, ivel);
	glActiveTexture(GL_TEXTURE1);
	glBindTexture(GL_TEXTURE_2D, ivorticity);
	glBegin(GL_QUADS);
		glMultiTexCoord3f(GL_TEXTURE0, 0, 0, 0.5); glVertex3f(-1,-1,0);
		glMultiTexCoord3f(GL_TEXTURE0, 1, 0, 0.5); glVertex3f(1,-1,0);
		glMultiTexCoord3f(GL_TEXTURE0, 1, 1, 0.5); glVertex3f(1,1,0);
		glMultiTexCoord3f(GL_TEXTURE0, 0, 1, 0.5); glVertex3f(-1,1,0);
	glEnd();
	
	glReadBuffer(GL_COLOR_ATTACHMENT1_EXT);
	
glReadPixels( 0, 0,  srcw, srch, GL_RGB, GL_FLOAT, texels);
glBindTexture(GL_TEXTURE_2D, ivel);	
glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB16F_ARB, srcw, srch, 0, GL_RGB, GL_FLOAT, texels);
free(texels);

glDrawBuffer(GL_COLOR_ATTACHMENT2_EXT);
				
	

	// buffer ink
	glDrawBuffer(GL_COLOR_ATTACHMENT2_EXT);
	
// add density 
	 
	
	glUseProgram(prog_ink);
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, iink);

	glBegin(GL_QUADS);
		glMultiTexCoord3f(GL_TEXTURE0, 0, 0, 0.5); glVertex3f(-1,-1,0);
		glMultiTexCoord3f(GL_TEXTURE0, 1, 0, 0.5); glVertex3f(1,-1,0);
		glMultiTexCoord3f(GL_TEXTURE0, 1, 1, 0.5); glVertex3f(1,1,0);
		glMultiTexCoord3f(GL_TEXTURE0, 0, 1, 0.5); glVertex3f(-1,1,0);
	glEnd();
// diffuse	
	glUseProgram(prog_diffusion);
	glActiveTexture(GL_TEXTURE0);
	
	glBindTexture(GL_TEXTURE_2D, iink);
	glBegin(GL_QUADS);
		glMultiTexCoord3f(GL_TEXTURE0, 0, 0, 0.5); glVertex3f(-1,-1,0);
		glMultiTexCoord3f(GL_TEXTURE0, 1, 0, 0.5); glVertex3f(1,-1,0);
		glMultiTexCoord3f(GL_TEXTURE0, 1, 1, 0.5); glVertex3f(1,1,0);
		glMultiTexCoord3f(GL_TEXTURE0, 0, 1, 0.5); glVertex3f(-1,1,0);
	glEnd();

// write ink
	//glDrawBuffer(GL_COLOR_ATTACHMENT2_EXT);
	
		glUseProgram(program);
		glUniform1f(glGetUniformLocation(program, "Dir"), -1);
		glUniform1f(glGetUniformLocation(program, "Conserve"), 0.99);
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, ivel);
	glActiveTexture(GL_TEXTURE1);
	glBindTexture(GL_TEXTURE_2D, iink);
	glBegin(GL_QUADS);
		glMultiTexCoord3f(GL_TEXTURE0, 0, 0, 0.5); glVertex3f(-1,-1,0);
		glMultiTexCoord3f(GL_TEXTURE0, 1, 0, 0.5); glVertex3f(1,-1,0);
		glMultiTexCoord3f(GL_TEXTURE0, 1, 1, 0.5); glVertex3f(1,1,0);
		glMultiTexCoord3f(GL_TEXTURE0, 0, 1, 0.5); glVertex3f(-1,1,0);
	glEnd();
	
	
// diffusion



	
	
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
	glPopAttrib();
}

- (void) draw
{
	glColor3f(1,1,1);
	glUseProgram(prog_sho);
	glEnable(GL_TEXTURE_2D);
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, iink);
	glBegin(GL_QUADS);
	glMultiTexCoord3f(GL_TEXTURE0, 0, 0, 0.5);
	glVertex3f(-1, -1, 0);
	glMultiTexCoord3f(GL_TEXTURE0, 1, 0, 0.5);
	glVertex3f(1, -1, 0);
	glMultiTexCoord3f(GL_TEXTURE0, 1, 1, 0.5);
	glVertex3f(1, 1, 0);
	glMultiTexCoord3f(GL_TEXTURE0, 0, 1, 0.5);
	glVertex3f(-1, 1, 0);
	glEnd();
	
	glTranslatef(2.01,0,0);
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, ivel);
	glBegin(GL_QUADS);
	glMultiTexCoord3f(GL_TEXTURE0, 0, 0, 0.5);
	glVertex3f(-1, -1, 0);
	glMultiTexCoord3f(GL_TEXTURE0, 1, 0, 0.5);
	glVertex3f(1, -1, 0);
	glMultiTexCoord3f(GL_TEXTURE0, 1, 1, 0.5);
	glVertex3f(1, 1, 0);
	glMultiTexCoord3f(GL_TEXTURE0, 0, 1, 0.5);
	glVertex3f(-1, 1, 0);
	glEnd();
	
	glTranslatef(0,-2.01,0);
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, ivorticity);
	glBegin(GL_QUADS);
	glMultiTexCoord3f(GL_TEXTURE0, 0, 0, 0.5);
	glVertex3f(-1, -1, 0);
	glMultiTexCoord3f(GL_TEXTURE0, 1, 0, 0.5);
	glVertex3f(1, -1, 0);
	glMultiTexCoord3f(GL_TEXTURE0, 1, 1, 0.5);
	glVertex3f(1, 1, 0);
	glMultiTexCoord3f(GL_TEXTURE0, 0, 1, 0.5);
	glVertex3f(-1, 1, 0);
	glEnd();
	
	glTranslatef(-2.01,0,0);
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, idivergence);
	glBegin(GL_QUADS);
	glMultiTexCoord3f(GL_TEXTURE0, 0, 0, 0.5);
	glVertex3f(-1, -1, 0);
	glMultiTexCoord3f(GL_TEXTURE0, 1, 0, 0.5);
	glVertex3f(1, -1, 0);
	glMultiTexCoord3f(GL_TEXTURE0, 1, 1, 0.5);
	glVertex3f(1, 1, 0);
	glMultiTexCoord3f(GL_TEXTURE0, 0, 1, 0.5);
	glVertex3f(-1, 1, 0);
	glEnd();
	
	glTranslatef(0, -2.01,0);
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D, ipressure);
	glBegin(GL_QUADS);
	glMultiTexCoord3f(GL_TEXTURE0, 0, 0, 0.5);
	glVertex3f(-1, -1, 0);
	glMultiTexCoord3f(GL_TEXTURE0, 1, 0, 0.5);
	glVertex3f(1, -1, 0);
	glMultiTexCoord3f(GL_TEXTURE0, 1, 1, 0.5);
	glVertex3f(1, 1, 0);
	glMultiTexCoord3f(GL_TEXTURE0, 0, 1, 0.5);
	glVertex3f(-1, 1, 0);
	glEnd();
	
	glUseProgram(0);
}

- (void) initGL
{
	int i;	
	
	
	
	
	glGenFramebuffersEXT(1, &buffbo);
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, buffbo);
	
	

	srcw = srch = 64;
	
	//checkEXRDim("/Users/jianzhang/Desktop/noivel.exr", &srcw, &srch);
	float *texels = malloc(srcw*srch*3*sizeof(float));
	//readEXRRGB("/Users/jianzhang/Desktop/noivel.exr", srcw, srch, texels);
	
	for(i=0;i<srcw*srch*3;i++) texels[i] =0;
	glGenTextures(1, &ivel);	
	glBindTexture(GL_TEXTURE_2D, ivel);	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

	
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB16F_ARB, srcw, srch, 0, GL_RGB, GL_FLOAT, texels);
	glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, ivel, 0);
	
	 GLenum status;                                           
        status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);
        if(status !=  GL_FRAMEBUFFER_COMPLETE_EXT ) NSLog(@"failed fbo");
		
		
		
		
	glGenTextures(1, &bufvel);	
	glBindTexture(GL_TEXTURE_2D, bufvel);	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB16F_ARB, srcw, srcw, 0, GL_RGB, GL_FLOAT, 0);
	
	
	glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT1_EXT, GL_TEXTURE_2D, bufvel, 0);
	

	                                    
        status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);
        if(status !=  GL_FRAMEBUFFER_COMPLETE_EXT ) NSLog(@"failed fbo");
		
		
		glGenTextures(1, &iink);	
	glBindTexture(GL_TEXTURE_2D, iink);	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	

	
	
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB16F_ARB, srcw, srcw, 0, GL_RGB, GL_FLOAT, texels);
	free(texels);
	
	glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT2_EXT, GL_TEXTURE_2D, iink, 0);
	

	                                    
        status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);
        if(status !=  GL_FRAMEBUFFER_COMPLETE_EXT ) NSLog(@"failed fbo");
		
	glGenTextures(1, &reversed);	
	glBindTexture(GL_TEXTURE_2D, reversed);	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB16F_ARB, srcw, srcw, 0, GL_RGB, GL_FLOAT, 0);
	
	glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT3_EXT, GL_TEXTURE_2D, reversed, 0);
                               
        status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);
        if(status !=  GL_FRAMEBUFFER_COMPLETE_EXT ) NSLog(@"failed fbo");
		
		glGenTextures(1, &forward);	
	glBindTexture(GL_TEXTURE_2D, forward);	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB16F_ARB, srcw, srcw, 0, GL_RGB, GL_FLOAT, 0);
	
	glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT4_EXT, GL_TEXTURE_2D, forward, 0);
                               
        status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);
        if(status !=  GL_FRAMEBUFFER_COMPLETE_EXT ) NSLog(@"failed fbo");
		
		glGenTextures(1, &ivorticity);	
	glBindTexture(GL_TEXTURE_2D, ivorticity);	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB16F_ARB, srcw, srcw, 0, GL_RGB, GL_FLOAT, 0);
	
	glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT5_EXT, GL_TEXTURE_2D, ivorticity, 0);
                               
        status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);
        if(status !=  GL_FRAMEBUFFER_COMPLETE_EXT ) NSLog(@"failed fbo");
		
		
		glGenTextures(1, &idivergence);	
	glBindTexture(GL_TEXTURE_2D, idivergence);	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB16F_ARB, srcw, srcw, 0, GL_RGB, GL_FLOAT, 0);
	
	glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT6_EXT, GL_TEXTURE_2D, idivergence, 0);
                               
        status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);
        if(status !=  GL_FRAMEBUFFER_COMPLETE_EXT ) NSLog(@"failed fbo");
		
		glGenTextures(1, &ipressure);	
	glBindTexture(GL_TEXTURE_2D, ipressure);	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB16F_ARB, srcw, srcw, 0, GL_RGB, GL_FLOAT, 0);
	
	glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT7_EXT, GL_TEXTURE_2D, ipressure, 0);
                               
        status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);
        if(status !=  GL_FRAMEBUFFER_COMPLETE_EXT ) NSLog(@"failed fbo");
	
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);

	[self initShaders];
	[self uniformParam];
	
	glInited = 1;
}

- (void)uniformParam
{
/* Setup uniforms */
		
}

- (void)initShaders
{
	//const char *vertex_string   = [vert_source cString];
	//const char *fragment_string   = [frag_source cString];
		const char *vert_src = "varying vec3  TexCoord;"


"void main(void)"
"{"
"    TexCoord        = gl_MultiTexCoord0.xyz;"

"    gl_Position     = ftransform();"
"}";

// advection shader
const char* src_advect = "uniform sampler2D VelocityUnit;"
"uniform sampler2D QuantityUnit;"

"varying vec3  TexCoord;"

"uniform float Dir;"
"uniform float Conserve;"

"vec2 Advect(vec2 cell, vec2 u)"
"{"
"vec2 fwdcell = cell.xy + u/64.0 * Dir;"
"	float x0 = floor(fwdcell.x*64.0-0.5)+0.5;"
"	float y0 = floor(fwdcell.y*64.0-0.5)+0.5;"
"	float x1 = x0+1.0;"
"	float y1 = y0+1.0;"
"	vec2 A = texture2D(QuantityUnit, vec2(x0, y0)/64.0).xy;"
"	vec2 B = texture2D(QuantityUnit, vec2(x1, y0)/64.0).xy;"
"	vec2 C = texture2D(QuantityUnit, vec2(x0, y1)/64.0).xy;"
"	vec2 D = texture2D(QuantityUnit, vec2(x1, y1)/64.0).xy;"
"	float alpha = fwdcell.x*64.0 - x0;"
"	float beta = fwdcell.y*64.0 - y0;"
"return A*(1.0 - alpha)*(1.0 - beta) + B* alpha *(1.0 - beta) + C*(1.0 - alpha)* beta + D* alpha * beta;"
"}"

"void main (void)"
"{" 
"	vec2 x = TexCoord.xy;"
"	vec2 u = texture2D(VelocityUnit, x).xy;" 
"	vec2 adv = Advect(x, u) * Conserve;"

"    gl_FragColor = vec4 (adv, 0.0, 1.0);"
"}";

GLuint vertex_shader   = glCreateShader(GL_VERTEX_SHADER);
	glShaderSource(vertex_shader, 1, &vert_src, 0);
	glCompileShader(vertex_shader);
	
	GLint shader_compiled;
	glGetShaderiv(vertex_shader, GL_COMPILE_STATUS, (GLint*)&shader_compiled);
	if(!shader_compiled) NSLog(vert_source);

	GLuint fragment_shader   = glCreateShader(GL_FRAGMENT_SHADER);
	glShaderSource(fragment_shader, 1, &src_advect, 0);
	glCompileShader(fragment_shader);
	
	glGetShaderiv(fragment_shader, GL_COMPILE_STATUS, (GLint*)&shader_compiled);
	if(!shader_compiled) NSLog(frag_source);
	
	program = glCreateProgram();
	
	glAttachShader(program, vertex_shader);
	glAttachShader(program, fragment_shader);
	
	glLinkProgram(program);
	
	GLint linked;
	glGetProgramiv(program, GL_LINK_STATUS, &linked);
	
	if(!linked) NSLog(@"advect failed to initialize");
	
	glUseProgram(program);
		glUniform1i(glGetUniformLocation(program, "VelocityUnit"), 0);
		glUniform1i(glGetUniformLocation(program, "QuantityUnit"), 1);
		glUniform1f(glGetUniformLocation(program, "Dir"), 1);
		glUseProgram(0);
	
	prog_diffusion = glCreateProgram();
	
	glAttachShader(prog_diffusion, vertex_shader);
	
const char* src_diffusion = "uniform sampler2D VelocityUnit;"

"varying vec3  TexCoord;"

"vec2 Diffusion(vec2 x)"
"{"
"	vec2 cell = texture2D(VelocityUnit, x).xy;"
"	float epsilon = 1.0/64.0;"
"	vec2 left = texture2D(VelocityUnit, x+vec2(-epsilon,0.0)).xy;"
"	vec2 right = texture2D(VelocityUnit, x+vec2(epsilon,0.0)).xy;"
"	vec2 bottom = texture2D(VelocityUnit, x+vec2(0.0, -epsilon)).xy;"
"	vec2 top = texture2D(VelocityUnit, x+vec2(0.0, epsilon)).xy;"
"return cell + (left+right+bottom+top-cell*4.0)*0.06;"
"}"

"void main (void)"
"{" 
"	vec2 x = TexCoord.xy;"
"	vec2 u = Diffusion(x);"
"    gl_FragColor = vec4 (u, 0.0, 1.0);"
"}";

	glShaderSource(fragment_shader, 1, &src_diffusion, 0);
	glCompileShader(fragment_shader);
	glAttachShader(prog_diffusion, fragment_shader);
	
	glLinkProgram(prog_diffusion);
	
	glGetProgramiv(prog_diffusion, GL_LINK_STATUS, &linked);
	
	if(!linked) NSLog(@"diffusion program failed to initialize");
	
	glUseProgram(prog_diffusion);
		glUniform1i(glGetUniformLocation(prog_diffusion, "VelocityUnit"), 0);
		glUseProgram(0);
		
const char* src_add = "uniform sampler2D VelocityUnit;"

"uniform sampler2D DensityUnit;"

"varying vec3  TexCoord;"

"vec2 Add(vec2 x)"
"{"
"	vec2 u = texture2D(VelocityUnit, x).xy;"
"	if(abs(x.x - 0.5)<0.05 && abs(x.y - 0.1)<0.1) {"
//"u.y += (1.0 - (x.x-0.5)*5.0)*0.0148;"
"u.x += (1.0 - (x.x-0.5)*5.0)*0.0148;"
"}"
"u.y += texture2D(DensityUnit, x).x*0.0148;"
"return u;"
"}"

"void main (void)"
"{" 
"	vec2 x = TexCoord.xy;"
"	vec2 u = Add(x);"
"    gl_FragColor = vec4 (u, 0.0, 1.0);"
"}";

prog_add = glCreateProgram();
	
	glAttachShader(prog_add, vertex_shader);
	
	glShaderSource(fragment_shader, 1, &src_add, 0);
	glCompileShader(fragment_shader);
	glAttachShader(prog_add, fragment_shader);
	
	glLinkProgram(prog_add);
	
	glGetProgramiv(prog_add, GL_LINK_STATUS, &linked);
	
	if(!linked) NSLog(@"add program failed to initialize");
	
	glUseProgram(prog_add);
		glUniform1i(glGetUniformLocation(prog_add, "VelocityUnit"), 0);
		glUniform1i(glGetUniformLocation(prog_add, "DensityUnit"), 1);
		glUseProgram(0);
		
		
		const char* src_swirl = "uniform sampler2D VelocityUnit;"
"uniform sampler2D VorticityUnit;"

"varying vec3  TexCoord;"

"vec2 bilinearinterp(vec2 x)"
"{"
"	float x0 = floor(x.x*64.0-0.5)+0.5;"
"	float y0 = floor(x.y*64.0-0.5)+0.5;"
"	float x1 = x0+1.0;"
"	float y1 = y0+1.0;"
"	vec2 A = texture2D(VelocityUnit, vec2(x0, y0)/64.0).xy;"
"	vec2 B = texture2D(VelocityUnit, vec2(x1, y0)/64.0).xy;"
"	vec2 C = texture2D(VelocityUnit, vec2(x0, y1)/64.0).xy;"
"	vec2 D = texture2D(VelocityUnit, vec2(x1, y1)/64.0).xy;"
"	float alpha = x.x*64.0 - x0;"
"	float beta = x.y*64.0 - y0;"
"return A*(1.0 - alpha)*(1.0 - beta) + B* alpha *(1.0 - beta) + C*(1.0 - alpha)* beta + D* alpha * beta;"
"}"

"float Vorticity(vec2 x)"
"{"
"	float epsilon = 1.0/64.0;"
"	vec2 left = bilinearinterp( x+vec2(-epsilon,0.0));"
"	vec2 right = bilinearinterp(x+vec2(epsilon,0.0));"
"	vec2 bottom = bilinearinterp( x+vec2(0.0, -epsilon));"
"	vec2 top = bilinearinterp( x+vec2(0.0, epsilon));"
"	return (top.x - bottom.x)*0.5 - (right.y - left.y)*0.5;"
"}"

"vec2 Swirl(vec2 x)"
"{"
"	vec2 cell = texture2D(VelocityUnit, x).xy;"

"	float epsilon = 1.0/64.0;"
"	float left = texture2D(VorticityUnit, x+vec2(-epsilon,0.0)).r;"
"	float right = texture2D(VorticityUnit, x+vec2(epsilon,0.0)).r;"
"	float bottom = texture2D(VorticityUnit, x+vec2(0.0, -epsilon)).r;"
"	float top = texture2D(VorticityUnit, x+vec2(0.0, epsilon)).r;"

"	vec2 force = vec2( abs(right) - abs(left) , abs(top) - abs(bottom) ) * 0.5;"
"	float mag = max(0.0001, dot(force, force));"
"	force /= sqrt(mag);"
"	float v = Vorticity(x);"
"	vec2 vforce  = vec2( -force.y *v, force.x*v);"
"return cell+vforce*0.22;"
"}"

"void main (void)"
"{" 
"	vec2 x = TexCoord.xy;"
"	vec2 u = Swirl(x);"
"    gl_FragColor = vec4 (u, 0.0, 1.0);"
"}";

prog_swirl = glCreateProgram();
	
	glAttachShader(prog_swirl, vertex_shader);
	
	glShaderSource(fragment_shader, 1, &src_swirl, 0);
	glCompileShader(fragment_shader);
	glAttachShader(prog_swirl, fragment_shader);
	
	glLinkProgram(prog_swirl);
	
	glGetProgramiv(prog_swirl, GL_LINK_STATUS, &linked);
	
	if(!linked) NSLog(@"swirl program failed to initialize");
	
	glUseProgram(prog_swirl);
		glUniform1i(glGetUniformLocation(prog_swirl, "VelocityUnit"), 0);
		glUniform1i(glGetUniformLocation(prog_swirl, "VorticityUnit"), 1);
		glUseProgram(0);
		
		prog_sho = glCreateProgram();
	
	glAttachShader(prog_sho, vertex_shader);
	
			const char* src_sho = "uniform sampler2D ShoUnit;"

"varying vec3 TexCoord;"

"vec2 bilinearinterp(vec2 x)"
"{"
"	float x0 = floor(x.x*64.0-0.5)+0.5;"
"	float y0 = floor(x.y*64.0-0.5)+0.5;"
"	float x1 = x0+1.0;"
"	float y1 = y0+1.0;"
"	vec2 A = texture2D(ShoUnit, vec2(x0, y0)/64.0).xy;"
"	vec2 B = texture2D(ShoUnit, vec2(x1, y0)/64.0).xy;"
"	vec2 C = texture2D(ShoUnit, vec2(x0, y1)/64.0).xy;"
"	vec2 D = texture2D(ShoUnit, vec2(x1, y1)/64.0).xy;"
"	float alpha = x.x*64.0 - x0;"
"	float beta = x.y*64.0 - y0;"
"return A*(1.0 - alpha)*(1.0 - beta) + B* alpha *(1.0 - beta) + C*(1.0 - alpha)* beta + D* alpha * beta;"
"}"

"void main (void)"
"{" 
"	vec2 x = TexCoord.xy;"
"	vec3 c = vec3(bilinearinterp(x),0.0);"
"    gl_FragColor = vec4 (c*0.5+0.5, 1.0);"
"}";
	
	glShaderSource(fragment_shader, 1, &src_sho, 0);
	glCompileShader(fragment_shader);
	glAttachShader(prog_sho, fragment_shader);
	
	glLinkProgram(prog_sho);
	
	glGetProgramiv(prog_sho, GL_LINK_STATUS, &linked);
	
	if(!linked) NSLog(@"sho program failed to initialize");
	
	glUseProgram(prog_sho);
		glUniform1i(glGetUniformLocation(prog_sho, "ShoUnit"), 0);
		glUseProgram(0);
		
		
		
		prog_ink = glCreateProgram();
	
	glAttachShader(prog_ink, vertex_shader);
	
			const char* src_ink = "uniform sampler2D InkUnit;"

"varying vec3  TexCoord;"

"float Add(vec2 x)"
"{"
"	float u = texture2D(InkUnit, x).x;"
"	if(abs(x.x - 0.5)<0.05 && abs(x.y - 0.1)<0.1) u += 0.1-abs(x.x-0.5)*0.5;"
"return u;"
"}"

"void main (void)"
"{" 
"	vec2 x = TexCoord.xy;"
"	float u = Add(x);"
"    gl_FragColor = vec4 (u, u, u, 1.0);"
"}";
	
	glShaderSource(fragment_shader, 1, &src_ink, 0);
	glCompileShader(fragment_shader);
	glAttachShader(prog_ink, fragment_shader);
	
	glLinkProgram(prog_ink);
	
	glGetProgramiv(prog_ink, GL_LINK_STATUS, &linked);
	
	if(!linked) NSLog(@"ink program failed to initialize");
	
	glUseProgram(prog_ink);
		glUniform1i(glGetUniformLocation(prog_ink, "InkUnit"), 0);
		glUseProgram(0);
		
		
// maccormack advection
	prog_maccormack = glCreateProgram();
	
	glAttachShader(prog_maccormack, vertex_shader);
	
			const char* src_maccormack = "uniform sampler2D VelocityUnit;"
			"uniform sampler2D ForwardUnit;"
			"uniform sampler2D OriginUnit;"

"varying vec3  TexCoord;"

"void main (void)"
"{" 
"	vec2 x = TexCoord.xy;"

"	vec2 phi_hat_n_1 = texture2D(ForwardUnit, x).xy;"

"	vec2 u = texture2D(VelocityUnit, x).xy;"
"	vec2 revcell = x - u/64.0 * 0.25;"
"	vec2 phi_hat_n = texture2D(ForwardUnit, revcell).xy;"

"	vec2 phi_n = texture2D(OriginUnit, x).xy;"

"	float epsilon = 1.0/ 64.0 * 0.5;"
"	vec2 left = texture2D(OriginUnit, revcell+vec2(-epsilon,0.0)).xy;"
"	vec2 right = texture2D(OriginUnit, revcell+vec2(epsilon,0.0)).xy;"
"	vec2 bottom = texture2D(OriginUnit, revcell+vec2(0.0, -epsilon)).xy;"
"	vec2 top = texture2D(OriginUnit, revcell+vec2(0.0, epsilon)).xy;"

"	vec2 phi_n_1 = phi_hat_n_1 + (phi_n - phi_hat_n) * 0.5;"

"	vec2 phimin = min(min(min(left, right), bottom),top);"
"	vec2 phimax = max(max(max(left, right), bottom),top);"

"    gl_FragColor = vec4 (max(min(phi_n_1, phimax), phimin), 0.0, 1.0);"
"}";
	
	glShaderSource(fragment_shader, 1, &src_maccormack, 0);
	glCompileShader(fragment_shader);
	glAttachShader(prog_maccormack, fragment_shader);
	
	glLinkProgram(prog_maccormack);
	
	glGetProgramiv(prog_maccormack, GL_LINK_STATUS, &linked);
	
	if(!linked) NSLog(@"maccormack program failed to initialize");
	
	glUseProgram(prog_maccormack);
		glUniform1i(glGetUniformLocation(prog_maccormack, "VelocityUnit"), 0);
		glUniform1i(glGetUniformLocation(prog_maccormack, "ForwardUnit"), 1);
		glUniform1i(glGetUniformLocation(prog_maccormack, "OriginUnit"), 2);
		glUseProgram(0);
		
// vorticity shader
	prog_vorticity = glCreateProgram();
	
	glAttachShader(prog_vorticity, vertex_shader);
	
			const char* src_vorticity = "uniform sampler2D VelocityUnit;"

"varying vec3  TexCoord;"

"void main (void)"
"{" 
"	vec2 x = TexCoord.xy;"

"	float epsilon = 1.0/ 64.0;"
"	vec2 left = texture2D(VelocityUnit, x+vec2(-epsilon,0.0)).xy;"
"	vec2 right = texture2D(VelocityUnit, x+vec2(epsilon,0.0)).xy;"
"	vec2 bottom = texture2D(VelocityUnit, x+vec2(0.0, -epsilon)).xy;"
"	vec2 top = texture2D(VelocityUnit, x+vec2(0.0, epsilon)).xy;"

"	float du_dy = top.x - bottom.x;"
"	float dv_dx = right.y - left.y;"
"	float v = du_dy - dv_dx;"
"    gl_FragColor = vec4 (v, v, v, 1.0);"
"}";
	
	glShaderSource(fragment_shader, 1, &src_vorticity, 0);
	glCompileShader(fragment_shader);
	glAttachShader(prog_vorticity, fragment_shader);
	
	glLinkProgram(prog_vorticity);
	
	glGetProgramiv(prog_vorticity, GL_LINK_STATUS, &linked);
	
	if(!linked) NSLog(@"vorticity program failed to initialize");
	
	glUseProgram(prog_vorticity);
		glUniform1i(glGetUniformLocation(prog_vorticity, "VelocityUnit"), 0);
// divergence shader
	prog_divergence = glCreateProgram();
	
	glAttachShader(prog_divergence, vertex_shader);
	
			const char* src_divergence = "uniform sampler2D VelocityUnit;"

"varying vec3  TexCoord;"

"void main (void)"
"{" 
"	vec2 x = TexCoord.xy;"

"	float epsilon = 1.0/ 64.0;"
"	vec2 left = texture2D(VelocityUnit, x+vec2(-epsilon,0.0)).xy;"
"	vec2 right = texture2D(VelocityUnit, x+vec2(epsilon,0.0)).xy;"
"	vec2 bottom = texture2D(VelocityUnit, x+vec2(0.0, -epsilon)).xy;"
"	vec2 top = texture2D(VelocityUnit, x+vec2(0.0, epsilon)).xy;"

"	float v = right.x - left.x + top.y - bottom.y;"
"    gl_FragColor = vec4 (v, v, v, 1.0);"
"}";
	
	glShaderSource(fragment_shader, 1, &src_divergence, 0);
	glCompileShader(fragment_shader);
	glAttachShader(prog_divergence, fragment_shader);
	
	glLinkProgram(prog_divergence);
	
	glGetProgramiv(prog_divergence, GL_LINK_STATUS, &linked);
	
	if(!linked) NSLog(@"divergence program failed to initialize");
	
	glUseProgram(prog_divergence);
		glUniform1i(glGetUniformLocation(prog_divergence, "VelocityUnit"), 0);
		
// jacobi
	prog_jacobi = glCreateProgram();
	
	glAttachShader(prog_jacobi, vertex_shader);
	
			const char* src_jacobi = "uniform sampler2D x;"
"uniform sampler2D b;"
"varying vec3  TexCoord;"

"void main (void)"
"{" 
"	vec2 pos = TexCoord.xy;"

"	float epsilon = 1.0/ 64.0;"
"	float left = texture2D(x, pos+vec2(-epsilon,0.0)).r;"
"	float right = texture2D(x, pos+vec2(epsilon,0.0)).r;"
"	float bottom = texture2D(x, pos+vec2(0.0, -epsilon)).r;"
"	float top = texture2D(x, pos+vec2(0.0, epsilon)).r;"

"	float c = (left+right+bottom+top - texture2D(b, pos ).r)/6.0;"
"    gl_FragColor = vec4 (c, c, c, 1.0);"
"}";
	
	glShaderSource(fragment_shader, 1, &src_jacobi, 0);
	glCompileShader(fragment_shader);
	glAttachShader(prog_jacobi, fragment_shader);
	
	glLinkProgram(prog_jacobi);
	
	glGetProgramiv(prog_jacobi, GL_LINK_STATUS, &linked);
	
	if(!linked) NSLog(@"jacobi program failed to initialize");
	
	glUseProgram(prog_jacobi);
		glUniform1i(glGetUniformLocation(prog_jacobi, "x"), 0);
		glUniform1i(glGetUniformLocation(prog_jacobi, "b"), 1);
		
// gradient
	prog_gradient = glCreateProgram();
	
	glAttachShader(prog_gradient, vertex_shader);
	
			const char* src_gradient = "uniform sampler2D p;"
"uniform sampler2D u;"
"varying vec3  TexCoord;"

"void main (void)"
"{" 
"	vec2 pos = TexCoord.xy;"

"	float epsilon = 1.0/ 64.0;"

"	float left = texture2D(p, pos+vec2(-epsilon,0.0)).r;"
"	float right = texture2D(p, pos+vec2(epsilon,0.0)).r;"
"	float bottom = texture2D(p, pos+vec2(0.0, -epsilon)).r;"
"	float top = texture2D(p, pos+vec2(0.0, epsilon)).r;"

"	vec2 unew = texture2D(u, pos).xy;"
"	unew -= vec2( right - left, top - bottom)*0.5;"
"    gl_FragColor = vec4 (unew, 0.0, 1.0);"
"}";
	
	glShaderSource(fragment_shader, 1, &src_gradient, 0);
	glCompileShader(fragment_shader);
	glAttachShader(prog_gradient, fragment_shader);
	
	glLinkProgram(prog_gradient);
	
	glGetProgramiv(prog_gradient, GL_LINK_STATUS, &linked);
	
	if(!linked) NSLog(@"gradient program failed to initialize");
	
	glUseProgram(prog_gradient);
		glUniform1i(glGetUniformLocation(prog_gradient, "u"), 0);
		glUniform1i(glGetUniformLocation(prog_gradient, "p"), 1);
}
@end

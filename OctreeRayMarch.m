//
//  RayMarch.m
//  triangle
//
//  Created by jian zhang on 1/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "OctreeRayMarch.h"
#import "zmath.h"
#import "perlin.h"

@implementation OctreeRayMarch
- (id) init
{
	[super init];
	name = @"OctreeRayMarch";
	
	glInited = 0;
	
	vert_source =

@"varying vec3  RayVec;"
"varying vec3  RayOrigin;"

"void main(void)"
"{"
"	vec3 eye = vec3(0.0,0.0,6.0);"
"    RayVec        = gl_MultiTexCoord0.xyz - eye;"
"    RayVec        = normalize(RayVec);"
"	RayOrigin = gl_MultiTexCoord0.xyz;"
"    gl_Position     = ftransform();"
"}";

	frag_source =
@"uniform sampler3D DensityUnit;"
"uniform sampler3D WhiteNoise;"

"varying vec3  RayVec;"
"varying vec3  RayOrigin;"

"float fractal_func(vec3 pcoord)"
"{"
"	float f=1.0;"

"	float fractal = texture3D(WhiteNoise, pcoord).r+0.5;" 
"	f*= 2.0;"
"	fractal +=  texture3D(WhiteNoise, pcoord*f).r/f;" 
"	f*= 2.0;"
"	fractal +=  texture3D(WhiteNoise, pcoord*f).r/f;" 
"	f*= 2.0;"
"	fractal +=  texture3D(WhiteNoise, pcoord*f).r/f;" 
"	f*= 2.0;"
"	fractal +=  texture3D(WhiteNoise, pcoord*f).r/f;"
"	f*= 2.0;"
"	fractal +=  texture3D(WhiteNoise, pcoord*f).r/f;" 
/*
"	float fractal = texture3D(WhiteNoise, pcoord).r;" 
"	f*= 2.0;"
"	fractal += (texture3D(WhiteNoise, pcoord*f).r-0.5)/f;" 
"	f*= 2.0;"
"	fractal += (texture3D(WhiteNoise, pcoord*f).r-0.5)/f;" 
"	f*= 2.0;"
"	fractal += (texture3D(WhiteNoise, pcoord*f).r-0.5)/f;" 
"	f*= 2.0;"
"	fractal += (texture3D(WhiteNoise, pcoord*f).r-0.5)/f;"
*/
"return clamp(fractal,0.0, 1.0);"
"}"

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
"if(hit.x > 0.01) num_step = (hit.y - hit.x)/0.04;"

"vec3 m = vec3(0.0);"
"float i, step_size, ray_length, weight;"
"vec3 sp;"
"vec4 vol;"
"float acc_dens= 0.0;"
"float dif_dens;"
"for(i=0.0; i < num_step; i++) {"
"	step_size = num_step - i;"
"	if(step_size > 1.0) step_size = 1.0;"

"	ray_length = hit.x + i * 0.04;"
"	sp = RayOrigin + RayVec * ray_length;"

"	sp = sp*0.5 + vec3(0.5);"

"	vol = texture3D(DensityUnit, sp);"
//"	weight = fractal_func((sp + vec3(47.117, 79.293, 67.717))*0.5);"
//"weight = pow(weight, 2.0);"
"weight = 0.5*vol.a * step_size;"
"weight = fractal_func((sp + vec3(47.117, 79.293, 67.717))*0.1);"
"weight = clamp((weight - 0.4)*1.25, 0.0, 1.0) * step_size * vol.a;"
"dif_dens = acc_dens;"
"	acc_dens += (1.0 - acc_dens) * weight;"
"dif_dens = acc_dens - dif_dens;"
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
	glPushAttrib(GL_ALL_ATTRIB_BITS);
	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, ifbo);
	glViewport(0,0,256, 256);
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
	glEnable(GL_TEXTURE_3D);
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_3D, voltex);
	glActiveTexture(GL_TEXTURE1);
	glBindTexture(GL_TEXTURE_3D, noitex);
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
	glDisable(GL_TEXTURE_3D);
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
	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA16F_ARB, 256, 256, 0, GL_RED, GL_FLOAT, 0);
	
	
	glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, itex, 0);
	
	 GLenum status;                                           
        status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT);
        if(status !=  GL_FRAMEBUFFER_COMPLETE_EXT ) NSLog(@"failed fbo");

	glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
	
// 3d texture
	glGenTextures(1, &voltex);	
	glBindTexture(GL_TEXTURE_3D, voltex);	
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER);
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER);
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_BORDER);
	
int DENSITY_WIDTH = 100;
int DENSITY_HEIGHT = 100;
int DENSITY_DEPTH = 100;

	float *texels = malloc( DENSITY_WIDTH * DENSITY_HEIGHT * DENSITY_DEPTH * 4 * sizeof(float));
	int u, v, w;
	float tx, ty, tz, den;
	for(w=0; w< DENSITY_DEPTH; w++) {
		for(v=0; v< DENSITY_HEIGHT; v++) {
			for(u=0; u< DENSITY_WIDTH; u++) {
				texels[(w*( DENSITY_WIDTH * DENSITY_HEIGHT)+v * DENSITY_WIDTH + u)*4] =  (float)(w)/100.f;
				texels[(w*( DENSITY_WIDTH * DENSITY_HEIGHT)+v * DENSITY_WIDTH + u)*4+1] =  (float)(w)/100.f;
				texels[(w*( DENSITY_WIDTH * DENSITY_HEIGHT)+v * DENSITY_WIDTH + u)*4+2] =  (float)(w)/100.f;
				tx = u - 49.f; 
				ty = v - 49.f; 
				tz = w - 49.f; 
				den = sqrt(tx*tx + ty*ty + tz*tz)/50;
				
				den = 1.0 - den;
				den *= 4;
				if(den >1 )den = 1;
					
				
				
				
				if(den < 0) den =0;
				
				texels[(w*( DENSITY_WIDTH * DENSITY_HEIGHT)+v * DENSITY_WIDTH + u)*4+3] = den;
				
				//texels[(w*( DENSITY_WIDTH * DENSITY_HEIGHT)+v * DENSITY_WIDTH + u)*4] *=den;
				//texels[(w*( DENSITY_WIDTH * DENSITY_HEIGHT)+v * DENSITY_WIDTH + u)*4+1]  *=den;
				//texels[(w*( DENSITY_WIDTH * DENSITY_HEIGHT)+v * DENSITY_WIDTH + u)*4+2]  *=den;
				
			}
		}
	}
	glTexImage3D(GL_TEXTURE_3D, 0, GL_RGBA16F_ARB, DENSITY_WIDTH, DENSITY_HEIGHT, DENSITY_DEPTH, 0, GL_RGBA, GL_FLOAT, texels);
	free(texels);
	
	int noise_w = 128;
	int noise_h = 128;
	int noise_d = 128;
	
	double ni[3];
	double inci, incj, inck;
	ni[0] = ni[1] = ni[2] = 0;
	SetNoiseFrequency(64);
	
	inck = 1.0/2.0; incj = 1.0/2.0; inci = 1.0/2.0;
	
	float *noi = malloc( noise_w * noise_h * noise_d * sizeof(float));
//srand(32019);	
	for(w=0; w< noise_d; w++) {
		ni[0] += inck;
		for(v=0; v< noise_h; v++) {
			ni[1] += incj;
			for(u=0; u< noise_w; u++) {//noi[ w*  noise_w * noise_h  + v * noise_w + u] = (float)(random()%511)/511.f;
				ni[2] += inci;
				noi[ w*  noise_w * noise_h  + v * noise_w + u] = noise3(ni);
			}
		}
	}
			
	float *down_pix = malloc(noise_w/2 * noise_h/2 * noise_d/2*sizeof(float));
	
	for(w=0; w< noise_d/2; w++)
		for(v=0; v< noise_h/2; v++)
			for(u=0; u< noise_w/2; u++) down_pix[w*  noise_w /2 * noise_h /2  + v * noise_w /2 + u] = downSample3D(u, v, w, noise_w, noise_h, noise_d, noi);

	
	float *up_pix = malloc(noise_w * noise_h * noise_d*sizeof(float));
	
	for(w=0; w< noise_d; w++)
		for(v=0; v< noise_h; v++)
			for(u=0; u< noise_w; u++) up_pix[w*  noise_w * noise_h  + v * noise_w + u] = upSample3D(u, v, w, noise_w/2, noise_h/2, noise_d/2, down_pix);

	
	for(w=0; w< noise_d; w++)
		for(v=0; v< noise_h; v++)
			for(u=0; u< noise_w; u++) noi[w*  noise_w * noise_h  + v * noise_w + u] = noi[w*  noise_w * noise_h  + v * noise_w + u] - up_pix[w*  noise_w * noise_h  + v * noise_w + u];

	
glGenTextures(1, &noitex);	
	glBindTexture(GL_TEXTURE_3D, noitex);	
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_R, GL_REPEAT);
	
	glTexImage3D(GL_TEXTURE_3D, 0, GL_LUMINANCE16F_ARB, noise_w, noise_h, noise_d, 0, GL_RED, GL_FLOAT, noi);
	free(noi);
	free(down_pix);
	free(up_pix);
	
	[self initShaders];
	
	glUseProgram(program);
		glUniform1i(glGetUniformLocation(program, "DensityUnit"), 0);
		glUniform1i(glGetUniformLocation(program, "WhiteNoise"), 1);
		glUseProgram(0);
	
	glInited = 1;
}

@end

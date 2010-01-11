//
//  SimpleNoise.h
//  triangle
//
//  Created by jian zhang on 1/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TestPiece.h"

@interface MacCormack : TestPiece {

	GLuint buffbo;
	
	GLuint ivel; //attach to 0
	GLuint bufvel;  //attach to 1
	GLuint iink; //attach to 2
	GLuint reversed;  //attach to 3
	GLuint forward;  //attach to 4
	GLuint ivorticity; // attach to 5
	GLuint idivergence; // attach to 6
	GLuint ipressure; // attach to 7

	int srcw, srch;
	GLuint prog_diffusion;
	GLuint prog_add;
	GLuint prog_vorticity;
	GLuint prog_swirl;
	GLuint prog_sho;
	GLuint prog_ink;
	GLuint prog_maccormack;
	GLuint prog_divergence;
	GLuint prog_jacobi;
	GLuint prog_gradient;
}

- (id) init;

- (void)draw;
- (void)initGL;
- (void)uniformParam;
- (void)preflight;
- (void)initShaders;
@end

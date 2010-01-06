//
//  ScalarFBO.h
//  triangle
//
//  Created by jian zhang on 1/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TestPiece.h"

@interface RenderTo3DTex : TestPiece {
	GLuint itex;
	GLuint ifbo;
	GLuint tgvoltex;
	GLuint volfbo;
}

- (id) init;
- (void)preflight;
- (void)draw;
- (void)initGL;
@end

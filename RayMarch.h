//
//  ScalarFBO.h
//  triangle
//
//  Created by jian zhang on 1/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TestPiece.h"

@interface RayMarch : TestPiece {
	GLuint itex;
	GLuint ifbo;
	GLuint voltex;
	GLuint noitex;
}

- (id) init;
- (void)preflight;
- (void)draw;
- (void)initGL;
@end

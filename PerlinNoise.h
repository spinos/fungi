//
//  SimpleNoise.h
//  triangle
//
//  Created by jian zhang on 1/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TestPiece.h"

@interface PerlinNoise : TestPiece {
	GLuint texname;
}

- (id) init;

- (void)draw;
- (void)initGL;
@end

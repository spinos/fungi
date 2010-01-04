//
//  ScalarFBO.h
//  triangle
//
//  Created by jian zhang on 1/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TestPiece.h"

@interface ScalarFBO : TestPiece {
	GLuint ctexname;
	GLuint stexname;
	GLuint cfbo;
}

- (id) init;
- (void)preflight;
- (void)draw;
- (void)initGL;
@end

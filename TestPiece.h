//
//  TestPiece.h
//  triangle
//
//  Created by jian zhang on 1/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <OpenGL/gl.h>
#import <OpenGL/glext.h>
#import <OpenGL/glu.h>
#import <OpenGL/OpenGL.h>

#import "FloatAttr.h"

@interface TestPiece : NSObject {
	BOOL glInited;
	NSString *name;
	NSArray *float_attr_array;
	NSString *vert_source;
	NSString *frag_source;
	NSString *geom_source;
	GLuint program;
}

- (id) init;
- (NSString *) name;
- (void)setName:(NSString *) aname;
- (void) draw;
- (void)preflight;
- (void)initGL;
- (void)initShaders;
- (BOOL)isGLInited;
- (NSArray *)getFloatAttr;
- (void)updateUniformFloat;
@end

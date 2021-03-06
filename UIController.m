//
//  UIController.m
//  triangle
//
//  Created by jian zhang on 1/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UIController.h"
#import "WhiteNoise.h"
#import "FFTImage.h"
#import "SimpleNoise.h"
#import "WaveletNoise.h"
#import "DownUpSample.h"
#import "ScalarFBO.h"
#import "RayMarch.h"
#import "PerlinNoise.h"
#import "RenderTo3DTex.h"
#import "OctreeRayMarch.h"
#import "MacCormack.h"

@implementation UIController

- (id) init
{
	[super init];
	
	pieces = [NSArray arrayWithObjects:
	[[WhiteNoise alloc] init],
	[[MacCormack alloc] init],
	[[PerlinNoise alloc] init],
	[[FFTImage alloc] init],
	[[SimpleNoise alloc] init],
	[[WaveletNoise alloc] init],
	[[DownUpSample alloc] init],
	[[ScalarFBO alloc] init],
	[[RayMarch alloc] init],
	[[RenderTo3DTex alloc] init],
	[[OctreeRayMarch alloc] init],
	nil];
	
	[pieces retain];
	
	return self;
}

- (int) numberOfRowsInTableView: (NSTableView *) aTableView
{
	return [pieces count];
}

- (id) tableView: (NSTableView *) aTableView
       objectValueForTableColumn: (NSTableColumn *) aTableColumn                                                                 
       row: (int) rowIndex
{
	return [[pieces objectAtIndex: rowIndex] name];
}

- (void) tableViewSelectionDidChange: (NSNotification *) aNotification
{
// cleanup
	[attrib_array removeObjects:[[opengl_view piece] getFloatAttr]];
	
	unsigned int rowindex;
	TestPiece  *piece;

   rowindex = [table_view selectedRow];
   
   if ((rowindex < 0) || (rowindex >= [pieces count])) return;
   
	piece = [pieces objectAtIndex: rowindex];
	
	[opengl_view setPiece:piece];
	
	[attrib_array addObjects:[[opengl_view piece] getFloatAttr]];
	
}

@end

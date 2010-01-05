/*
 *  math.h
 *  cocoagl
 *
 *  Created by jian zhang on 1/4/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _MATH_H
#define _MATH_H

float downSample2D(int x, int y, int width, int height, float *data);
float upSample2D(int x, int y, int width, int height, float *data);

float downSample3D(int x, int y, int z, int width, int height, int depth, float *data);
float upSample3D(int x, int y, int z, int width, int height, int depth, float *data);

#endif
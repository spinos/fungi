/*
 *  image.c
 *  triangle
 *
 *  Created by jian zhang on 1/1/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "image.h"


void checkEXRDim(const char* filename, int* width, int* height)
{
	InputFile file(filename); 
	Box2i dw = file.header().dataWindow(); 
	*width  = dw.max.x - dw.min.x + 1;
	*height = dw.max.y - dw.min.y + 1;
}

void readEXRRED(const char* filename, int width, int height, float* data)
{
	InputFile file(filename); 
	Box2i dw = file.header().dataWindow();
	
	int size = (width)*(height);
	
	half *rPixels = new half[size];
	
	FrameBuffer frameBuffer; 
	frameBuffer.insert ("R",                                  // name 
						Slice (HALF,                          // type 
							   (char *) rPixels, 
							   sizeof (*rPixels) * 1,    // xStride 
							   sizeof (*rPixels) * (width),// yStride 
							   1, 1,                          // x/y sampling 
							   0.0));                         // fillValue 
							   
	file.setFrameBuffer (frameBuffer); 
	file.readPixels (dw.min.y, dw.max.y); 
	
	for(int j=0; j<height; j++)
	for(int i=0; i<width; i++) {
		
		data[j*width+i] = rPixels[(height-1-j)*width+i];
		
	}
	
	delete[] rPixels;
}

void readEXRRGB(const char* filename, int width, int height, float* data)
{
	InputFile file(filename); 
	Box2i dw = file.header().dataWindow();
	
	int size = (width)*(height);
	
	half *rPixels = new half[size];
	half *gPixels = new half[size];
	half *bPixels = new half[size];
	
	FrameBuffer frameBuffer; 
	frameBuffer.insert ("R",                                  // name 
						Slice (HALF,                          // type 
							   (char *) rPixels, 
							   sizeof (*rPixels) * 1,    // xStride 
							   sizeof (*rPixels) * (width),// yStride 
							   1, 1,                          // x/y sampling 
							   0.0));                         // fillValue 
							   
	frameBuffer.insert ("G",                                  // name 
						Slice (HALF,                          // type 
							   (char *) gPixels, 
							   sizeof (*gPixels) * 1,    // xStride 
							   sizeof (*gPixels) * (width),// yStride 
							   1, 1,                          // x/y sampling 
							   0.0));
							   
	frameBuffer.insert ("B",                                  // name 
						Slice (HALF,                          // type 
							   (char *) bPixels, 
							   sizeof (*bPixels) * 1,    // xStride 
							   sizeof (*bPixels) * (width),// yStride 
							   1, 1,                          // x/y sampling 
							   0.0));
							   
	file.setFrameBuffer (frameBuffer); 
	file.readPixels (dw.min.y, dw.max.y); 
	
	for(int j=0; j<height; j++)
	for(int i=0; i<width; i++) {
		
		data[(j*width+i)*3 ] = rPixels[(height-1-j)*width+i];
		data[(j*width+i)*3+1] = gPixels[(height-1-j)*width+i];
		data[(j*width+i)*3+2] = bPixels[(height-1-j)*width+i];
	}
	
	delete[] rPixels;
	delete[] gPixels;
	delete[] bPixels;
}

void saveEXRRGBA(const char* filename, int width, int height, float* data)
{
	half *idr_r = new half[ width * height];
	half *idr_g = new half[ width * height];
	half *idr_b = new half[ width * height];
	half *idr_a = new half[ width * height];
	
	for(int j=0; j< height; j++) {
		int invj = height - 1 -j;
		for(int i=0; i< width; i++) {
			idr_r[j* width + i] = (half)data[(invj* width + i)*4];
			idr_g[j* width + i] = (half)data[(invj* width + i)*4+1];
			idr_b[j* width + i] = (half)data[(invj* width + i)*4+2];
			idr_a[j* width + i] = (half)data[(invj* width + i)*4+3];
		}
	}
// write exr
	Header idrheader ( width,  height); 

		idrheader.channels().insert ("R", Channel (HALF));
		idrheader.channels().insert ("G", Channel (HALF));                                   // 1 
        idrheader.channels().insert ("B", Channel (HALF));
		idrheader.channels().insert ("A", Channel (HALF));                   // 2  
    
        OutputFile idrfile (filename, idrheader);                               // 4 
        FrameBuffer idrframeBuffer;
		 idrframeBuffer.insert ("R",                                // name   // 6 
                            Slice (HALF,                        // type   // 7 
                                   (char *) idr_r,            // base   // 8 
                                   sizeof (*idr_r) * 1,       // xStride// 9 
                                   sizeof (*idr_r) *  width));
        idrframeBuffer.insert ("G",                                // name   // 6 
                            Slice (HALF,                        // type   // 7 
                                   (char *) idr_g,            // base   // 8 
                                   sizeof (*idr_g) * 1,       // xStride// 9 
                                   sizeof (*idr_g) *  width));
		 idrframeBuffer.insert ("B",                                // name   // 6 
                            Slice (HALF,                        // type   // 7 
                                   (char *) idr_b,            // base   // 8 
                                   sizeof (*idr_b) * 1,       // xStride// 9 
                                   sizeof (*idr_b) *  width));
		 idrframeBuffer.insert ("A",                                // name   // 6 
                            Slice (HALF,                        // type   // 7 
                                   (char *) idr_a,            // base   // 8 
                                   sizeof (*idr_a) * 1,       // xStride// 9 
                                   sizeof (*idr_a) *  width));
       
        idrfile.setFrameBuffer (idrframeBuffer);                                // 16 
        idrfile.writePixels ( height); 
        
// cleanup
	delete[] idr_r;
	delete[] idr_g;
	delete[] idr_b;
	delete[] idr_a;
}


#import <Cocoa/Cocoa.h>
#import "TestPiece.h"
 
@interface myGLView : NSOpenGLView
{
	double lastFrameReferenceTime;
	NSTimer *timer;
	
	TestPiece *piece;
	
	bool leftMouseIsDown;
	bool rightMouseIsDown;
	NSPoint lastMousePoint;
	
	float eyex, eyey, eyez;
	
	GLuint fbo;
	GLuint texfbo;
}

- (void) updateProjection;
- (void) updateModelView;
- (void) resizeGL;

- (void) drawRect:(NSRect)rect;

- (void) prepareOpenGL;
- (id) initWithFrame: (NSRect) frameRect;
 
- (TestPiece *)piece;
- (void)setPiece:(TestPiece *) apiece;

- (IBAction)snapshot:(id)sender;

@end
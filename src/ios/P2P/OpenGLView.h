//
//  OpenGLView.h
//  iVideoCalls
//
//  Created by Kiwaro Nigas on 12-12-4.
//  Copyright (c) 2012年 xizue.com. All rights reserved.
//

#import "P2PCInterface.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "Constants.h"
#import "P2PClient.h"

#define g_w 352
#define g_h 240

enum {
	ATTRIBUTE_VERTEX,
   	ATTRIBUTE_TEXCOORD,
};

@protocol OpenGLRenderer
- (BOOL) isValid;
- (NSString *) fragmentShader;
- (void) resolveUniforms: (GLuint) program;
- (void) setFrame:(GAVFrame *)yuvFrame;
- (BOOL) prepareRender;
@end

@protocol OpenGLViewDelegate <NSObject>
-(void)onScreenShotted:(UIImage*)image;
@end

@interface OpenGLView : UIView
{
    EAGLContext     *_context;
    GLuint          _framebuffer;
    GLuint          _renderbuffer;
    GLuint          _program;
    GLint           _uniformMatrix;
    
    id<OpenGLRenderer> _renderer;
    
    //YES表示渲染成功，退出时可截图；NO表示渲染失败或渲染未完成（一片黑），退出时不截图
    BOOL            _isGetVideoFrame;
    CGFloat         _viewScale;
}
@property (nonatomic) BOOL Initialized;
@property (nonatomic) BOOL isScreenShotting;
@property (nonatomic) BOOL captureFinishScreen;
@property (nonatomic) BOOL isQuitMonitorInterface;//rtsp监控界面弹出修改
@property (assign) id<OpenGLViewDelegate> delegate;
- (BOOL)isvalid;
- (void)render:(GAVFrame *)frame;
- (UIImage *)glToUIImage;

@end


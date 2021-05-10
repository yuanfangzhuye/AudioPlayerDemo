//
//  CameraOverlayView.m
//  AudioPlayerDemo
//
//  Created by lab team on 2021/4/27.
//

#import "CameraOverlayView.h"

@implementation CameraOverlayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    self.statusView = [[StatusView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 48.0)];
    [self addSubview:self.statusView];
    
    self.modeView = [[CameraModeView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 110.0 - 34.0 - 44.0, [UIScreen mainScreen].bounds.size.width, 110.0)];
    [self addSubview:self.modeView];
    
    [self.modeView addTarget:self action:@selector(modeChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)modeChanged:(CameraModeView *)modeView {
    BOOL photoModeEnabled = modeView.cameraMode == THCameraModePhoto;
    UIColor *toColor = photoModeEnabled ? [UIColor blackColor] : [UIColor colorWithWhite:0 alpha:0.5];
    CGFloat toOpacity = photoModeEnabled ? 0.0 : 1.0;
    self.statusView.layer.backgroundColor = toColor.CGColor;
    self.statusView.elapsedTimeLabel.layer.opacity = toOpacity;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    if ([self.statusView pointInside:[self convertPoint:point toView:self.statusView] withEvent:event] || [self.modeView pointInside:[self convertPoint:point toView:self.modeView] withEvent:event]) {
        
        return YES;
    }
    
    return NO;
}

- (void)setFlashControlHidden:(BOOL)flashControlHidden {
    if (_flashControlHidden != flashControlHidden) {
        _flashControlHidden = flashControlHidden;
        self.statusView.flashControl.hidden = flashControlHidden;
    }
}


@end

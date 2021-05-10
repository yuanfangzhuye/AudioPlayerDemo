//
//  CameraButton.m
//  AudioPlayerDemo
//
//  Created by lab team on 2021/5/6.
//

#import "CameraButton.h"

#define LINE_WIDTH 6.0f
#define DEFAULT_FRAME CGRectMake(0.0f, 0.0f, 68.0f, 68.0f)

@interface CameraButton ()

@property (nonatomic, strong) CALayer *circleLayer;

@end

@implementation CameraButton

+ (instancetype)captureButton {
    return [[self alloc] initWithCaptureButtonWithMode:THCaptureButtonModeVideo];
}

+ (instancetype)captureButtonWithMode:(THCaptureButtonMode)captureButtonMode {
    return [[self alloc] initWithCaptureButtonWithMode:captureButtonMode];
}

- (instancetype)initWithCaptureButtonWithMode:(THCaptureButtonMode)mode {
    self = [super initWithFrame:DEFAULT_FRAME];
    if (self) {
        _captureButtonMode = mode;
        [self setupView];
    }
    
    return self;
}

- (void)setupView {
    self.backgroundColor = [UIColor clearColor];
    self.layer.cornerRadius = 34.0f;
    self.layer.masksToBounds = YES;
    self.tintColor = [UIColor clearColor];
    
    UIColor *circleColor = (self.captureButtonMode == THCaptureButtonModeVideo) ? [UIColor redColor] : [UIColor whiteColor];
    _circleLayer = [CALayer layer];
    _circleLayer.backgroundColor = circleColor.CGColor;
    _circleLayer.bounds = CGRectInset(self.bounds, 8.0, 8.0);
    _circleLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _circleLayer.cornerRadius = _circleLayer.bounds.size.width / 2.0;
    [self.layer addSublayer:_circleLayer];
}

- (void)setCaptureButtonMode:(THCaptureButtonMode)captureButtonMode {
    if (_captureButtonMode != captureButtonMode) {
        _captureButtonMode = captureButtonMode;
        UIColor *toColor = (captureButtonMode == THCaptureButtonModeVideo) ? [UIColor redColor] : [UIColor whiteColor];
        self.circleLayer.backgroundColor = toColor.CGColor;
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    fadeAnimation.duration = 0.2f;
    if (highlighted) {
        fadeAnimation.toValue = @(0.0);
    }
    else {
        fadeAnimation.toValue = @(1.0);
    }
    
    self.circleLayer.opacity = [fadeAnimation.toValue floatValue];
    [self.circleLayer addAnimation:fadeAnimation forKey:@"fadeAnimation"];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (self.captureButtonMode == THCaptureButtonModeVideo) {
        [CATransaction disableActions];
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        CABasicAnimation *radiusAnimation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
        
        if (selected) {
            scaleAnimation.toValue = @0.6;
            radiusAnimation.toValue = @(self.circleLayer.bounds.size.width / 4.0);
        }
        else {
            scaleAnimation.toValue = @1.0;
            radiusAnimation.toValue = @(self.circleLayer.bounds.size.width / 2.0);
        }
        
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.animations = @[scaleAnimation, radiusAnimation];
        animationGroup.beginTime = CACurrentMediaTime() + 0.2;
        animationGroup.duration = 0.35;
        
        [self.circleLayer setValue:radiusAnimation.toValue forKeyPath:@"cornerRadius"];
        [self.circleLayer setValue:scaleAnimation.toValue forKeyPath:@"transform.scale"];
//        animationGroup.animations = @[radiusAnimation, scaleAnimation];
        
        [self.circleLayer addAnimation:animationGroup forKey:@"scaleAndRadiusAnimation"];
    }
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, LINE_WIDTH);
    
    CGRect insertRect = CGRectInset(rect, LINE_WIDTH / 2.0, LINE_WIDTH / 2.0);
    CGContextStrokeEllipseInRect(context, insertRect);
}


@end

//
//  CameraView.m
//  AudioPlayerDemo
//
//  Created by lab team on 2021/4/27.
//

#import "CameraView.h"

@interface CameraView ()

@property (nonatomic, strong) CameraPreview *previewView;
@property (nonatomic, strong) CameraOverlayView *overlayView;

@end

@implementation CameraView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
}

@end

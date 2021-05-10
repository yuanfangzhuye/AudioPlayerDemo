//
//  StatusView.m
//  AudioPlayerDemo
//
//  Created by lab team on 2021/5/7.
//

#import "StatusView.h"
#import "UIView+LCFrame.h"

@implementation StatusView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [self setupView];
    }
    return self;
}

- (void)setupView {
    
    self.flashControl = [[FlashControl alloc] initWithFrame:CGRectMake(10, 0, 66, 48)];
    self.flashControl.delegate = self;
    [self addSubview:self.flashControl];
    
    self.elapsedTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 100) / 2, 11, 100, 26)];
    self.elapsedTimeLabel.textColor = [UIColor whiteColor];
    self.elapsedTimeLabel.text = @"00:00:00";
    self.elapsedTimeLabel.textAlignment = NSTextAlignmentCenter;
    self.elapsedTimeLabel.font = [UIFont systemFontOfSize:13];
    [self addSubview:self.elapsedTimeLabel];
    
    self.switchCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.switchCameraButton setImage:[UIImage imageNamed:@"camera_icon"] forState:UIControlStateNormal];
    self.switchCameraButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 48.0, 0, 48.0, 48.0);
    [self addSubview:self.switchCameraButton];
}

- (void)flashControlWillExpand {
    [UIView animateWithDuration:0.2f animations:^{
        self.elapsedTimeLabel.alpha = 0.0f;
    }];
}

- (void)flashControlDidCollapse {
    [UIView animateWithDuration:0.1f animations:^{
        self.elapsedTimeLabel.alpha = 1.0f;
    }];
}


@end

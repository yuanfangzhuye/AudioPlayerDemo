//
//  StatusView.h
//  AudioPlayerDemo
//
//  Created by lab team on 2021/5/7.
//

#import <UIKit/UIKit.h>
#import "FlashControl.h"

NS_ASSUME_NONNULL_BEGIN

@interface StatusView : UIView <FlashControlDelegate>

@property (strong, nonatomic) FlashControl *flashControl;
@property (strong, nonatomic) UILabel *elapsedTimeLabel;
@property (nonatomic, strong) UIButton *switchCameraButton;

@end

NS_ASSUME_NONNULL_END

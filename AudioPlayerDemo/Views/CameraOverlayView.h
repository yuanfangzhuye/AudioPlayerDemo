//
//  CameraOverlayView.h
//  AudioPlayerDemo
//
//  Created by lab team on 2021/4/27.
//

#import <UIKit/UIKit.h>
#import "CameraModeView.h"
#import "StatusView.h"

NS_ASSUME_NONNULL_BEGIN

@interface CameraOverlayView : UIView

@property (nonatomic, strong) CameraModeView *modeView;
@property (nonatomic, strong) StatusView *statusView;

@property (nonatomic) BOOL flashControlHidden;

@end

NS_ASSUME_NONNULL_END

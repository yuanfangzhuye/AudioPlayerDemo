//
//  CameraModeView.h
//  AudioPlayerDemo
//
//  Created by lab team on 2021/5/7.
//

#import <UIKit/UIKit.h>
#import "CameraButton.h"

typedef NS_ENUM(NSUInteger, THCameraMode) {
    THCameraModePhoto = 0, // default
    THCameraModeVideo = 1
};

NS_ASSUME_NONNULL_BEGIN

@interface CameraModeView : UIControl

@property (nonatomic, strong) UIButton *thumbnailButton;
@property (strong, nonatomic) CameraButton *captureButton;
@property (nonatomic, assign) THCameraMode cameraMode;

@end

NS_ASSUME_NONNULL_END

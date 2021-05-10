//
//  CameraButton.h
//  AudioPlayerDemo
//
//  Created by lab team on 2021/5/6.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, THCaptureButtonMode) {
    THCaptureButtonModePhoto = 0, // default
    THCaptureButtonModeVideo = 1
};

NS_ASSUME_NONNULL_BEGIN

@interface CameraButton : UIButton

+ (instancetype)captureButton;
+ (instancetype)captureButtonWithMode:(THCaptureButtonMode)captureButtonMode;

@property (nonatomic) THCaptureButtonMode captureButtonMode;

@end

NS_ASSUME_NONNULL_END

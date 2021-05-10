//
//  CameraPreview.h
//  AudioPlayerDemo
//
//  Created by lab team on 2021/4/27.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol THPreviewViewDelegate <NSObject>
- (void)tappedToFocusAtPoint:(CGPoint)point;//聚焦
- (void)tappedToExposeAtPoint:(CGPoint)point;//曝光
- (void)tappedToResetFocusAndExposure;//点击重置聚焦&曝光
@end

NS_ASSUME_NONNULL_BEGIN

@interface CameraPreview : UIView

//session用来关联AVCaptureVideoPreviewLayer 和 激活AVCaptureSession
@property (strong, nonatomic) AVCaptureSession *session;
@property (weak, nonatomic) id<THPreviewViewDelegate> delegate;

@property (nonatomic) BOOL tapToFocusEnabled; //是否聚焦
@property (nonatomic) BOOL tapToExposeEnabled; //是否曝光

@end

NS_ASSUME_NONNULL_END

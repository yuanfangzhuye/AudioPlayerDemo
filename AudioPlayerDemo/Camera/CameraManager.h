//
//  CameraManager.h
//  AudioPlayerDemo
//
//  Created by lab team on 2021/4/25.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

extern NSString *const ThumbnailCreatedNotification;

@protocol CameraFailedDelegate <NSObject>

// 发生错误事件是，需要在对象委托上调用一些方法来处理
- (void)deviceConfigurationFailedWithErrror:(NSError *)error;
- (void)mediaCaptureFailedWithError:(NSError *)error;
- (void)assetLibraryWriteFailedWithError:(NSError *)error;

@end

@interface CameraManager : NSObject

@property (nonatomic, weak) id<CameraFailedDelegate>delegate;
@property (nonatomic, strong, readonly) AVCaptureSession *captureSession;

// 设置、配置视频捕捉会话
- (BOOL)setupSession:(NSError **)error;
- (void)startSession;
- (void)stopSession;

// 切换摄像头
- (BOOL)canSwitchCamera;
- (BOOL)switchCamera;

@property (nonatomic, readonly) NSUInteger cameraCount;
@property (nonatomic, readonly) BOOL cameraSupportTapToFocus; //聚焦
@property (nonatomic, readonly) BOOL cameraSupportTapToExpose; //曝光
@property (nonatomic, readonly) BOOL cameraHasFlash; //闪光灯
@property (nonatomic, readonly) BOOL cameraHasTorch; //手电筒

@property (nonatomic) AVCaptureTorchMode torchMode; //手电筒模式
@property (nonatomic) AVCaptureFlashMode flashMode; //闪光灯模式

// 聚焦、曝光、重设聚焦、曝光的方法
- (void)focusAtPoint:(CGPoint)point;
- (void)exposeAtPoint:(CGPoint)point;
- (void)resetFocusAndExposureModes;

//捕捉静态图片
- (void)captureStillImage;

//开始录制（视频）
- (void)startRecording;

//停止录制（视频）
- (void)stopRecording;

//获取录制状态（视频）
- (BOOL)isRecording;

//录制时间（视频）
- (CMTime)recordedDuration;

@end

//
//  CameraManager.m
//  AudioPlayerDemo
//
//  Created by lab team on 2021/4/25.
//

#import "CameraManager.h"
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "NSFileManager+Additions.h"

NSString *const ThumbnailCreatedNotification = @"ThumbnailCreated";

@interface CameraManager () <AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, strong) dispatch_queue_t vedioQueue;
@property (nonatomic, strong) AVCaptureSession *captureSession;

@property (nonatomic, strong) AVCaptureDeviceInput *captureVedioDeviceInput;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieFileOutput;

@property (nonatomic, strong) NSURL *outputURL;

@end

@implementation CameraManager


- (BOOL)setupSession:(NSError **)error {
    
    // 创建捕捉会话
    self.captureSession = [[AVCaptureSession alloc] init];
    
    // 设置图像分辨率
    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    
    // 默认的视频捕捉会话（后置摄像头）
    AVCaptureDevice *captureVedioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 为会话添加捕捉设备，必须将设备封装成 AVCaptureDeviceInput 对象
    AVCaptureDeviceInput *captureVedioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureVedioDevice error:error];
    
    // 判断 captureVedioDeviceInput 是否有效
    if (captureVedioDeviceInput) {
        // 是否能被添加到会话中
        if ([self.captureSession canAddInput:captureVedioDeviceInput]) {
            [self.captureSession addInput:captureVedioDeviceInput];
            self.captureVedioDeviceInput = captureVedioDeviceInput;
        }
    }
    else {
        return NO;
    }
    
    // 默认的音频捕捉设备
    AVCaptureDevice *captureAudioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    
    // 为音频设备创建一个捕捉设备输入
    AVCaptureDeviceInput *captureAudioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureAudioDevice error:error];
    
    // 判断 captureAudioDeviceInput 是否有效
    if (captureAudioDeviceInput) {
        // 音频设备是否能被添加到会话中
        if ([self.captureSession canAddInput:captureAudioDeviceInput]) {
            // 将 captureAudioDeviceInput 添加到 captureSession中
            [self.captureSession addInput:captureAudioDeviceInput];
        }
    }
    else {
        return NO;
    }
    
    // 创建 AVCaptureStillImageOutput 实例 从摄像头捕捉静态图片
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    
    // 配置字典
    self.stillImageOutput.outputSettings = @{AVVideoCodecKey: AVVideoCodecJPEG};
    
    //输出连接 判断是否可用，可用则添加到输出连接中去
    if ([self.captureSession canAddOutput:self.stillImageOutput]) {
        [self.captureSession addOutput:self.stillImageOutput];
    }
    
    self.movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    
    //输出连接 判断是否可用，可用则添加到输出连接中去
    if ([self.captureSession canAddOutput:self.movieFileOutput]) {
        [self.captureSession addOutput:self.movieFileOutput];
    }
    
    self.vedioQueue = dispatch_queue_create("lc.vedio", NULL);
    
    return YES;
}


- (void)startSession {
    
    // 检查是否处于运行状态
    if (![self.captureSession isRunning]) {
        // 使用同步调用会损耗一定的时间，则用异步的方式处理
        dispatch_async(self.vedioQueue, ^{
            [self.captureSession startRunning];
        });
    }
}

- (void)stopSession {
    
    // 检查是否处于运行状态
    if ([self.captureSession isRunning]) {
        // 使用异步方式，停止运行
        dispatch_async(self.vedioQueue, ^{
            [self.captureSession stopRunning];
        });
    }
}


#pragma mark ---- 配置摄像头支持方法
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    
    // 获取可用视频设备
    NSArray *avaliableDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    //遍历可用的视频设备 并返回position 参数值
    for (AVCaptureDevice *device in avaliableDevices) {
        if (device.position == position) {
            return device;
        }
    }
    
    return nil;
}

// 当前会话的摄像头
- (AVCaptureDevice *)activeCamera {
    
    // 返回当前捕捉会话对应的摄像头的device 属性
    return self.captureVedioDeviceInput.device;
}

// 返回当前未激活的摄像头
- (AVCaptureDevice *)inactiveCamera {
    
    // 通过查找当前激活摄像头的反向摄像头获得，如果设备只有1个摄像头，则返回nil
    AVCaptureDevice *device = nil;
    if (self.cameraCount > 1) {
        if ([self activeCamera].position == AVCaptureDevicePositionBack) {
            device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        }
        else {
            device = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
    }
    
    return device;
}

// 判断是否有可以切换摄像头
- (BOOL)canSwitchCamera {
    return self.cameraCount > 1;
}

// 切换摄像头
- (BOOL)switchCamera {
    
    // 判断是否有多个摄像头
    if (![self canSwitchCamera]) {
        return NO;
    }
    
    // 获取当前设备的反向设备
    NSError *error;
    AVCaptureDevice *videoDevice = [self inactiveCamera];
    
    // 将输入设备封装成 AVCaptureDeviceInput
    AVCaptureDeviceInput *videoInput= [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    
    // 判断 videoInput 是否为nil
    if (videoInput) {
        
        // 标注原配置变化开始
        [self.captureSession beginConfiguration];
        
        // 将捕捉会话中，原本的捕捉输入设备移除
        [self.captureSession removeInput:self.captureVedioDeviceInput];
        
        // 判断新的设备是否能加入
        if ([self.captureSession canAddInput:videoInput]) {
            
            // 能加入成功，则将videoInput 作为新的视频捕捉设备
            [self.captureSession addInput:videoInput];
            
            // 将获得设备改为 videoInput
            self.captureVedioDeviceInput = videoInput;
        }
        else {
            // 如果新设备，无法加入。则将原本的视频捕捉设备重新加入到捕捉会话中
            [self.captureSession addInput:self.captureVedioDeviceInput];
        }
        
        // 配置完成后， AVCaptureSession commitConfiguration 会分批的将所有变更整合在一起。
        [self.captureSession commitConfiguration];
    }
    else {
        
        // 创建 AVCaptureDeviceInput 出现错误，则通知委托来处理该错误
        if (self.delegate && [self.delegate respondsToSelector:@selector(deviceConfigurationFailedWithErrror:)]) {
            [self.delegate deviceConfigurationFailedWithErrror:error];
            
            return NO;
        }
    }
    
    return YES;
}


- (NSUInteger)cameraCount {
    
    return [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count;
}


/*
    AVCapture Device 定义了很多方法，让开发者控制ios设备上的摄像头。可以独立调整和锁定摄像头的焦距、曝光、白平衡。对焦和曝光可以基于特定的兴趣点进行设置，使其在应用中实现点击对焦、点击曝光的功能。
    还可以让你控制设备的LED作为拍照的闪光灯或手电筒的使用
    
    每当修改摄像头设备时，一定要先测试修改动作是否能被设备支持。并不是所有的摄像头都支持所有功能，例如牵制摄像头就不支持对焦操作，因为它和目标距离一般在一臂之长的距离。但大部分后置摄像头是可以支持全尺寸对焦。尝试应用一个不被支持的动作，会导致异常崩溃。所以修改摄像头设备前，需要判断是否支持
 
 
 */


#pragma mark ---- 聚焦方法的实现
- (BOOL)cameraSupportTapToFocus {
    
    // 询问激活中的摄像头是否支持兴趣点对焦
    return [[self activeCamera] isFocusPointOfInterestSupported];
}

- (void)focusAtPoint:(CGPoint)point {
    
    AVCaptureDevice *device = [self activeCamera];
    
    // 是否支持兴趣点对焦 & 是否自动对焦模式
    if (device.isFocusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        NSError *error;
        
        // 锁定设备准备配置，如果获得了锁
        if ([device lockForConfiguration:&error]) {
            
            // 将 focusPointOfInterest 属性设置 CGPoint
            device.focusPointOfInterest = point;
            
            // focusMode 设置为 AVCaptureFocusModeAutoFocus
            device.focusMode = AVCaptureFocusModeAutoFocus;
            
            // 释放该锁定
            [device unlockForConfiguration];
        }
        else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(deviceConfigurationFailedWithErrror:)]) {
                [self.delegate deviceConfigurationFailedWithErrror:error];
            }
        }
    }
}


#pragma mark - 曝光方法实现
- (BOOL)cameraSupportTapToExpose {
    
    // 询问设备是否支持对一个兴趣点进行曝光
    return [[self activeCamera] isExposurePointOfInterestSupported];
}

static const NSString *CameraAdjustingExposureContext;

- (void)exposeAtPoint:(CGPoint)point {
    
    AVCaptureDevice *device = [self activeCamera];
    AVCaptureExposureMode exposureMode = AVCaptureExposureModeContinuousAutoExposure;
    
    // 判断是否支持 AVCaptureExposureModeContinuousAutoExposure 模式
    if (device.isExposurePointOfInterestSupported && [device isExposureModeSupported:exposureMode]) {
        [device isExposureModeSupported:exposureMode];
        
        NSError *error;
        
        // 锁定设备准备设置
        if ([device lockForConfiguration:&error]) {
            
            // 配置期望值
            device.exposurePointOfInterest = point;
            device.exposureMode = exposureMode;
            
            //判断设备是否支持锁定曝光的模式。
            if ([device isExposureModeSupported:AVCaptureExposureModeLocked]) {
                
                // 支持，则使用kvo确定设备的adjustingExposure属性的状态。
                [device addObserver:self forKeyPath:@"adjustingExposure" options:NSKeyValueObservingOptionNew context:&CameraAdjustingExposureContext];
            }
            
            // 释放该锁定
            [device unlockForConfiguration];
        }
        else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(deviceConfigurationFailedWithErrror:)]) {
                [self.delegate deviceConfigurationFailedWithErrror:error];
            }
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    // 判断context（上下文）是否为 CameraAdjustingExposureContext
    if (context == &CameraAdjustingExposureContext) {
        
        // 获取 device
        AVCaptureDevice *device = (AVCaptureDevice *)object;
        
        // 判断设备是否不再调整曝光等级，确认设备的exposureMode是否可以设置为AVCaptureExposureModeLocked
        if (!device.isAdjustingExposure && [device isExposureModeSupported:AVCaptureExposureModeLocked]) {
            
            // 移除作为 adjustingExposure 的 self，就不会得到后续变更的通知
            [object removeObserver:self forKeyPath:@"adjustingExposure" context:&CameraAdjustingExposureContext];
            
            // 异步方式调回主队列
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSError *error;
                if ([device lockForConfiguration:&error]) {
                    
                    // 修改 exposureMode
                    device.exposureMode = AVCaptureExposureModeLocked;
                    
                    // 释放该锁定
                    [device unlockForConfiguration];
                }
                else {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(deviceConfigurationFailedWithErrror:)]) {
                        [self.delegate deviceConfigurationFailedWithErrror:error];
                    }
                }
            });
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)resetFocusAndExposureModes {
    
    AVCaptureDevice *device = [self activeCamera];
    
    AVCaptureFocusMode focusMode = AVCaptureFocusModeContinuousAutoFocus;
    
    // 获取对焦兴趣点 和 连续自动对焦模式 是否被支持
    BOOL canResetFocus = [device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode];
    
    AVCaptureExposureMode exposureMode = AVCaptureExposureModeAutoExpose;
    
    //确认曝光度可以被重设
    BOOL canResetExposure = [device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode];
    
    // 捕捉设备空间左上角（0，0），右下角（1，1） 中心点则（0.5，0.5）
    CGPoint centerPoint = CGPointMake(0.5, 0.5);
    
    NSError *error;
    
    // 锁定设备，准备配置
    if ([device lockForConfiguration:&error]) {
        
        // 焦点可设，则修改
        if (canResetFocus) {
            device.focusMode = focusMode;
            device.focusPointOfInterest = centerPoint;
        }
        
        // 曝光度可设，则设置为期望的曝光模式
        if (canResetExposure) {
            device.exposureMode = exposureMode;
            device.exposurePointOfInterest = centerPoint;
        }
        
        // 释放锁定
        [device unlockForConfiguration];
    }
    else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(deviceConfigurationFailedWithErrror:)]) {
            [self.delegate deviceConfigurationFailedWithErrror:error];
        }
    }
}


#pragma mark - 闪光灯
- (BOOL)cameraHasFlash {
    return [[self activeCamera] hasFlash]; // 判断是否有闪光灯
}

// 闪光灯模式
- (AVCaptureFlashMode)flashMode {
    return [[self activeCamera] flashMode];
}

// 设置闪光灯
- (void)setFlashMode:(AVCaptureFlashMode)flashMode {
    
    // 获取会话
    AVCaptureDevice *device = [self activeCamera];
    
    // 判断是否支持闪光灯模式
    if ([device isFlashModeSupported:flashMode]) {
        
        NSError *error;
        
        // 如果支持，则锁定设备
        if ([device lockForConfiguration:&error]) {
            
            // 修改闪光灯模式
            device.flashMode = flashMode;
            
            // 修改完成，解锁释放设备
            [device unlockForConfiguration];
        }
        else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(deviceConfigurationFailedWithErrror:)]) {
                [self.delegate deviceConfigurationFailedWithErrror:error];
            }
        }
    }
}


#pragma mark - 手电筒
- (BOOL)cameraHasTorch {
    return [[self activeCamera] hasTorch];
}

// 手电筒模式
- (AVCaptureTorchMode)torchMode {
    return [[self activeCamera] torchMode];
}

- (void)setTorchMode:(AVCaptureTorchMode)mode {
    
    AVCaptureDevice *device = [self activeCamera];
    
    if ([device isTorchModeSupported:mode]) {
        
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.torchMode = mode;
            [device unlockForConfiguration];
        }
        else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(deviceConfigurationFailedWithErrror:)]) {
                [self.delegate deviceConfigurationFailedWithErrror:error];
            }
        }
    }
}


#pragma mark - 拍摄静态图片
/*
    AVCaptureStillImageOutput 是AVCaptureOutput的子类。用于捕捉图片
 */
- (void)captureStillImage {
    
    // 获取链接
    AVCaptureConnection *captureConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    
    if (captureConnection.supportsVideoOrientation) {
        captureConnection.videoOrientation = [self currentVideoOrientation];
    }
    
    id handle = ^(CMSampleBufferRef sampleBuffer, NSError *error) {
        if (sampleBuffer != NULL) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
            UIImage *img = [[UIImage alloc] initWithData:imageData];
            
            // 重点：捕捉图片成功后，将图片传递出去
            [self writeImageToAssetsLibrary:img];
        }
        else {
            NSLog(@"NULL sampleBuffer:%@",[error localizedDescription]);
        }
    };
    
    // 捕捉静态图片
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:handle];
}

// 获取方向值
- (AVCaptureVideoOrientation)currentVideoOrientation {
    
    AVCaptureVideoOrientation orientation;
    
    // 获取设备的 orientation
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
            
        default:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
    }
    
    return orientation;
}

/*
    Assets Library 框架
    用来让开发者通过代码方式访问iOS photo
    注意：会访问到相册，需要修改plist 权限。否则会导致项目崩溃
 */
- (void)writeImageToAssetsLibrary:(UIImage *)image {
    
    // 创建 PHPhotoLibrary 实例
    PHPhotoLibrary *photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
    [photoLibrary performChanges:^{
        [PHAssetCreationRequest creationRequestForAssetFromImage:image];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        // 成功后，发送捕捉图片通知。用于绘制程序的左下角的缩略图
        if (success) {
            [self postThumbnailNotification:image];
            NSLog(@"已将图片保存至相册");
        }
        else {
            //失败打印错误信息
            id message = [error localizedDescription];
            NSLog(@"%@",message);
        }
    }];
}

- (void)postThumbnailNotification:(UIImage *)image {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:ThumbnailCreatedNotification object:image];
    });
}


#pragma mark - 捕捉视频
// 是否正在录制状态
- (BOOL)isRecording {
    return self.movieFileOutput.isRecording;
}

// 开始录制
- (void)startRecording {
    if (![self isRecording]) {
        
        // 获取当前视频捕捉连接信息，用于捕捉视频数据配置一些核心属性
        AVCaptureConnection *captureConnection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        
        // 判断是否支持设置 videoOrientation 属性
        if ([captureConnection isVideoOrientationSupported]) {
            
            // 支持则修改当前视频的方向
            captureConnection.videoOrientation = [self currentVideoOrientation];
        }
        
        // 判断是否支持视频稳定 可以显著提高视频的质量。只会在录制视频文件涉及
        if ([captureConnection isVideoStabilizationSupported]) {
            captureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        }
        
        AVCaptureDevice *device = [self activeCamera];
        
        //
        if (device.isSmoothAutoFocusEnabled) {
            NSError *error;
            if ([device lockForConfiguration:&error]) {
                device.smoothAutoFocusEnabled = YES;
                [device unlockForConfiguration];
            }
            else {
                if (self.delegate && [self.delegate respondsToSelector:@selector(deviceConfigurationFailedWithErrror:)]) {
                    [self.delegate deviceConfigurationFailedWithErrror:error];
                }
            }
        }
        
        self.outputURL = [self uniqueURL];
        [self.movieFileOutput startRecordingToOutputFileURL:self.outputURL recordingDelegate:self];
    }
}

- (CMTime)recordedDuration {
    return self.movieFileOutput.recordedDuration;
}

//写入视频唯一文件系统URL
- (NSURL *)uniqueURL {
    
    NSString *dirPath = [[NSFileManager defaultManager] temporaryDirectoryWithTemplateString:@"kamera.XXXXXX"];
    if (dirPath) {
        NSString *filePath = [dirPath stringByAppendingPathComponent:@"kamera_movie.mov"];
        return [NSURL fileURLWithPath:filePath];
    }
    return nil;
}


// 停止录制
- (void)stopRecording {
    
    // 是否正在录制
    if ([self isRecording]) {
        [self.movieFileOutput stopRecording];
    }
}


#pragma mark - AVCaptureFileOutputRecordingDelegate
- (void)captureOutput:(nonnull AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(nonnull NSURL *)outputFileURL fromConnections:(nonnull NSArray<AVCaptureConnection *> *)connections error:(nullable NSError *)error {
    
    // 错误
    if (error) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(mediaCaptureFailedWithError:)]) {
            [self.delegate mediaCaptureFailedWithError:error];
        }
    }
    else {
        // 写入
        [self writeVideoToAssetsLibrary:[self.outputURL copy]];
    }
    
    self.outputURL = nil;
}

// 写入捕捉的视频
- (void)writeVideoToAssetsLibrary:(NSURL *)videoURL {
    // 创建 PHPhotoLibrary 实例
    PHPhotoLibrary *photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
    [photoLibrary performChanges:^{
        [PHAssetCreationRequest creationRequestForAssetFromVideoAtFileURL:videoURL];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        // 成功后，发送捕捉图片通知。用于绘制程序的左下角的缩略图
        if (success) {
            [self generateThumbnailForVideoAtURL:videoURL];
            NSLog(@"已将图片保存至相册");
        }
        else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(assetLibraryWriteFailedWithError:)]) {
                [self.delegate assetLibraryWriteFailedWithError:error];
            }
        }
    }];
}

//获取视频左下角缩略图
- (void)generateThumbnailForVideoAtURL:(NSURL *)videoURL {
    
    // 在 videoQueue 上
    dispatch_async(self.vedioQueue, ^{
        
        // 建立新的AVAsset & AVAssetImageGenerator
        AVAsset *asset = [AVAsset assetWithURL:videoURL];
        
        AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        
        // 设置maximumSize 宽为100，高为0 根据视频的宽高比来计算图片的高度
        imageGenerator.maximumSize = CGSizeMake(100.0, 0.0);
        
        // 捕捉视频缩略图会考虑视频的变化（如视频的方向变化），如果不设置，缩略图的方向可能出错
        imageGenerator.appliesPreferredTrackTransform = YES;
        
        // 获取CGImageRef图片 注意需要自己管理它的创建和释放
        CGImageRef imageRef = [imageGenerator copyCGImageAtTime:kCMTimeZero actualTime:NULL error:nil];
        
        // 将图片转化为 UIImage
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        
        // 释放CGImageRef imageRef 防止内存泄漏
        CGImageRelease(imageRef);
        
        // 回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // 发送通知，传递最新的image
            [self postThumbnailNotification:image];
        });
    });
}

@end

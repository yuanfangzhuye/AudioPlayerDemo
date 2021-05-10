//
//  ViewController.m
//  AudioPlayerDemo
//
//  Created by lab team on 2021/4/23.
//

#import "ViewController.h"
#import "CameraView.h"
#import "CameraManager.h"
#import "CameraPreview.h"
#import "FlashControl.h"
#import "CameraModeView.h"
#import "CameraOverlayView.h"
#import "NSTimer+Additions.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface ViewController () <THPreviewViewDelegate>

@property (nonatomic) THCameraMode cameraMode;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) CameraManager *cameraController;

@property (strong, nonatomic) CameraPreview *previewView;
@property (strong, nonatomic) CameraOverlayView *overlayView;
@property (nonatomic, strong) UIButton *thumbnailButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateThumbnail:) name:ThumbnailCreatedNotification object:nil];
    
    self.cameraMode = THCameraModeVideo;
    self.cameraController = [[CameraManager alloc] init];
    
    NSError *error;
    if ([self.cameraController setupSession:&error]) {
        [self.previewView setSession:self.cameraController.captureSession];
        self.previewView.delegate = self;
        [self.cameraController startSession];
    } else {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
    
    self.previewView.tapToFocusEnabled = self.cameraController.cameraSupportTapToFocus;
    self.previewView.tapToExposeEnabled = self.cameraController.cameraSupportTapToExpose;
    
}

- (void)setupUI {
    
    CameraView *cameraView = [[CameraView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:cameraView];
    
    self.previewView = cameraView.previewView;
    self.overlayView = cameraView.overlayView;
    self.thumbnailButton = self.overlayView.modeView.thumbnailButton;
    
    [self.overlayView.statusView.flashControl addTarget:self action:@selector(flashControlChanged:) forControlEvents:UIControlEventValueChanged];
    [self.overlayView.statusView.switchCameraButton addTarget:self action:@selector(swapCameras:) forControlEvents:UIControlEventTouchUpInside];
    [self.overlayView.modeView addTarget:self action:@selector(cameraModeChanged:) forControlEvents:UIControlEventValueChanged];
    [self.overlayView.modeView.thumbnailButton addTarget:self action:@selector(showCameraRoll:) forControlEvents:UIControlEventTouchUpInside];
    [self.overlayView.modeView.captureButton addTarget:self action:@selector(captureOrRecord:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)flashControlChanged:(id)sender {
    NSInteger mode = [(FlashControl *)sender selectedMode];
    if (self.cameraMode == THCameraModePhoto) {
        self.cameraController.flashMode = mode;
    } else {
        self.cameraController.torchMode = mode;
    }
}

- (void)swapCameras:(id)sender {
    if ([self.cameraController switchCamera]) {
        BOOL hidden = NO;
        if (self.cameraMode == THCameraModePhoto) {
            hidden = !self.cameraController.cameraHasFlash;
        } else {
            hidden = !self.cameraController.cameraHasTorch;
        }
        self.overlayView.flashControlHidden = hidden;
        self.previewView.tapToExposeEnabled = self.cameraController.cameraSupportTapToExpose;
        self.previewView.tapToFocusEnabled = self.cameraController.cameraSupportTapToFocus;
        [self.cameraController resetFocusAndExposureModes];
    }
}

- (void)cameraModeChanged:(id)sender {
    self.cameraMode = [sender cameraMode];
}

- (void)captureOrRecord:(UIButton *)sender {
    if (self.cameraMode == THCameraModePhoto) {
        [self.cameraController captureStillImage];
    } else {
        if (!self.cameraController.isRecording) {
            dispatch_async(dispatch_queue_create("com.tapharmonic.kamera", NULL), ^{
                [self.cameraController startRecording];
                [self startTimer];
            });
        } else {
            [self.cameraController stopRecording];
            [self stopTimer];
        }
        sender.selected = !sender.selected;
    }
}

- (void)showCameraRoll:(id)sender {
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    controller.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
    [self presentViewController:controller animated:YES completion:nil];
}

- (AVAudioPlayer *)playerWithResource:(NSString *)resourceName {
    NSURL *url = [[NSBundle mainBundle] URLForResource:resourceName withExtension:@"caf"];
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [player prepareToPlay];
    player.volume = 0.1f;
    return player;
}

- (void)startTimer {
    [self.timer invalidate];
    self.timer = [NSTimer timerWithTimeInterval:0.5
                                         target:self
                                       selector:@selector(updateTimeDisplay)
                                       userInfo:nil
                                        repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)updateTimeDisplay {
    CMTime duration = self.cameraController.recordedDuration;
    NSUInteger time = (NSUInteger)CMTimeGetSeconds(duration);
    NSInteger hours = (time / 3600);
    NSInteger minutes = (time / 60) % 60;
    NSInteger seconds = time % 60;
    
    NSString *format = @"%02i:%02i:%02i";
    NSString *timeString = [NSString stringWithFormat:format, hours, minutes, seconds];
    self.overlayView.statusView.elapsedTimeLabel.text = timeString;
}

- (void)updateThumbnail:(NSNotification *)notification {
    UIImage *image = notification.object;
    [self.thumbnailButton setBackgroundImage:image forState:UIControlStateNormal];
    self.thumbnailButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.thumbnailButton.layer.borderWidth = 1.0f;
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
    self.overlayView.statusView.elapsedTimeLabel.text = @"00:00:00";
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)tappedToFocusAtPoint:(CGPoint)point {
    [self.cameraController focusAtPoint:point];
}

- (void)tappedToExposeAtPoint:(CGPoint)point {
    [self.cameraController exposeAtPoint:point];
}

- (void)tappedToResetFocusAndExposure {
    [self.cameraController resetFocusAndExposureModes];
}

@end

//
//  CameraView.h
//  AudioPlayerDemo
//
//  Created by lab team on 2021/4/27.
//

#import <UIKit/UIKit.h>
#import "CameraPreview.h"
#import "CameraOverlayView.h"

@interface CameraView : UIView

@property (nonatomic, strong, readonly) CameraPreview *previewView;
@property (nonatomic, strong, readonly) CameraOverlayView *overlayView;

@end

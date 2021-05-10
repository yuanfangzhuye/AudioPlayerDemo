//
//  FlashControl.h
//  AudioPlayerDemo
//
//  Created by lab team on 2021/5/7.
//

#import <UIKit/UIKit.h>

@protocol FlashControlDelegate <NSObject>

@optional
- (void)flashControlWillExpand;
- (void)flashControlDidExpand;
- (void)flashControlWillCollapse;
- (void)flashControlDidCollapse;

@end

NS_ASSUME_NONNULL_BEGIN

@interface FlashControl : UIControl

@property (nonatomic, assign) NSInteger selectedMode;
@property (nonatomic, weak) id<FlashControlDelegate>delegate;

@end

NS_ASSUME_NONNULL_END

//
//  ViewController.m
//  AudioPlayerDemo
//
//  Created by lab team on 2021/4/23.
//

#import "ViewController.h"
#import "CameraManager.h"

@interface ViewController ()

@property (nonatomic, strong) UIButton *thumbnailButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateThumbnail:) name:ThumbnailCreatedNotification object:nil];
    
}

- (void)setupUI {
    self.thumbnailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.thumbnailButton.frame = CGRectMake(20, self.view.frame.size.height - 80, 50, 50);
    [self.view addSubview:self.thumbnailButton];
}


- (void)updateThumbnail:(NSNotification *)notification {
    UIImage *image = notification.object;
    [self.thumbnailButton setBackgroundImage:image forState:UIControlStateNormal];
    self.thumbnailButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.thumbnailButton.layer.borderWidth = 1.0f;
}


@end

//
//  CheckInViewController.m
//  LoyaltyPrototype
//
//  Created by Jason Grandelli on 1/23/13.
//  Copyright (c) 2013 URBN. All rights reserved.
//

#import "CheckInViewController.h"
#import "NavBarItemsViewController.h"
#import "UIFont+UrbanAdditions.h"
#import "BackgroundView.h"
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import "UserData.h"

@interface CheckInViewController ()

@property (nonatomic, strong) UIButton *checkinBtn;

@end

@implementation CheckInViewController

#define MARGIN 15.0f
#define PADDING 10.0f

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    int i = (arc4random() % 9) + 1;
    NSString *patternName = [NSString stringWithFormat:@"Background%i", i];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:patternName]];
    
    NavBarItemsViewController *navBarItems = [[NavBarItemsViewController alloc] init];
    navBarItems.pageName = @"Check-In";
    [navBarItems.view setFrame:self.navigationController.navigationBar.bounds];
    [self.navigationController.navigationBar addSubview:navBarItems.view];
    
    if ([self.navigationController.parentViewController respondsToSelector:@selector(revealGesture:)] &&
        [self.navigationController.parentViewController respondsToSelector:@selector(revealToggle:)])
    {
        UIPanGestureRecognizer *navigationBarPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self.navigationController.parentViewController action:@selector(revealGesture:)];
		[self.navigationController.navigationBar addGestureRecognizer:navigationBarPanGestureRecognizer];
		
		
        UIImage *leftImg = [UIImage imageNamed:@"menuBtn"];
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.frame = CGRectMake(10.0, 5.0, leftImg.size.width, leftImg.size.height);
        [leftButton setImage:leftImg forState:UIControlStateNormal];
        [leftButton addTarget:self.navigationController.parentViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationController.navigationBar addSubview:leftButton];
	}
    
    self.checkinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _checkinBtn.frame = CGRectMake(MARGIN, self.navigationController.navigationBar.frame.size.height + MARGIN, self.view.frame.size.width - MARGIN*2, 44.0);
    [_checkinBtn addTarget:self action:@selector(checkinBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_checkinBtn];

    BackgroundView *backView = [[BackgroundView alloc] initWithFrame:_checkinBtn.bounds];
    [_checkinBtn addSubview:backView];
    
    UIImage *iconImg = [UIImage imageNamed:@"store_locator"];
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(8.0, 8.0, 22.0, 22.0)];
    [iconView setImage:[self getImageWithUnsaturatedPixelsOfImage:iconImg]];
    iconView.tag = 10;
    [_checkinBtn addSubview:iconView];
    
    UILabel *btnLabel = [[UILabel alloc] initWithFrame:CGRectMake(iconView.frame.origin.x + iconView.frame.size.width + 5.0, PADDING + 1, 0.0, 0.0)];
    btnLabel.backgroundColor = [UIColor clearColor];
    btnLabel.textColor = [UIColor darkGrayColor];
    btnLabel.font = [UIFont fontNamedLoRes15BoldOaklandWithSize:16.0];
    btnLabel.text = @"Name this location";
    [btnLabel sizeToFit];
    btnLabel.tag = 11;
    [_checkinBtn addSubview:btnLabel];
    
    UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(_checkinBtn.frame.size.width - 28.0, 15.0, 10.0, 10.0)];
    [arrow setImage:[UIImage imageNamed:@"arrow_right"]];
    arrow.alpha = 0.7;
    [_checkinBtn addSubview:arrow];
}

- (void)checkinBtnPressed {
    //NSMutableURLRequest *request = [client requestWithMethod:@"GET" path:path parameters:nil];
    //[request setTimeoutInterval:30];

}

-(UIImage *)getImageWithUnsaturatedPixelsOfImage:(UIImage *)image {
    const int RED = 1, GREEN = 2, BLUE = 3;
    
    CGRect imageRect = CGRectMake(0, 0, image.size.width*2, image.size.height*2);
    
    int width = imageRect.size.width, height = imageRect.size.height;
    
    uint32_t * pixels = (uint32_t *) malloc(width*height*sizeof(uint32_t));
    memset(pixels, 0, width * height * sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [image CGImage]);
    
    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t * rgbaPixel = (uint8_t *) &pixels[y*width+x];
            uint32_t gray = (0.3*rgbaPixel[RED]+0.59*rgbaPixel[GREEN]+0.11*rgbaPixel[BLUE]);
            
            rgbaPixel[RED] = gray;
            rgbaPixel[GREEN] = gray;
            rgbaPixel[BLUE] = gray;
        }
    }
    
    CGImageRef newImage = CGBitmapContextCreateImage(context);
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    
    UIImage * resultUIImage = [UIImage imageWithCGImage:newImage scale:2 orientation:0];
    CGImageRelease(newImage);
    
    return resultUIImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

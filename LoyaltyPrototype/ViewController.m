//
//  ViewController.m
//  LoyaltyPrototype
//
//  Created by Jason Grandelli on 12/5/12.
//  Copyright (c) 2012 URBN. All rights reserved.
//

#import "ViewController.h"
#import "StatusViewController.h"
#import "MenuViewController.h"
#import "UIColor+ColorConstants.h"
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import <UIImageView+AFNetworking.h>

@interface ViewController() {
    UINavigationController *navController;
}
@end

@implementation ViewController

- (id)initWithFrontViewController:(UIViewController *)aFrontViewController rearViewController:(UIViewController *)aBackViewController {
	self = [super initWithFrontViewController:aFrontViewController rearViewController:aBackViewController];
	
	if (nil != self) {
		self.delegate = self;
        
        navController = (UINavigationController *)aFrontViewController;
	}
	
	return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //[self profileDataLoaded];
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)profileDataLoaded {
    CGRect frame;
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 2.0, self.view.bounds.size.width, 44.0)];
    nameLabel.textColor = [UIColor neonBlue];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.font = [UIFont boldSystemFontOfSize:16.0];
    nameLabel.text = @"Jason G.";
    frame = nameLabel.frame;
    [nameLabel sizeToFit];
    frame.size.height = nameLabel.frame.size.height;
    nameLabel.frame = frame;
    [navController.navigationBar addSubview:nameLabel];
    
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, frame.origin.y + frame.size.height + 3, self.view.bounds.size.width, 44.0)];
    statusLabel.textColor = [UIColor neonBlue];
    statusLabel.backgroundColor = [UIColor clearColor];
    statusLabel.textAlignment = NSTextAlignmentCenter;
    statusLabel.font = [UIFont boldSystemFontOfSize:12.0];
    statusLabel.text = @"Superior Being: 13500 pts";
    frame = statusLabel.frame;
    [statusLabel sizeToFit];
    frame.size.height = statusLabel.frame.size.height;
    statusLabel.frame = frame;
    [navController.navigationBar addSubview:statusLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

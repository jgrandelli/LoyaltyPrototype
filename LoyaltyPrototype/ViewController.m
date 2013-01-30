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
}
@end

@implementation ViewController

- (id)initWithFrontViewController:(UIViewController *)aFrontViewController rearViewController:(UIViewController *)aBackViewController {
	self = [super initWithFrontViewController:aFrontViewController rearViewController:aBackViewController];
	
	if (nil != self) {
		self.delegate = self;
	}
	
	return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

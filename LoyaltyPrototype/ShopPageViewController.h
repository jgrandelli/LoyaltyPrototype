//
//  ShopPageViewController.h
//  LoyaltyPrototype
//
//  Created by Jason Grandelli on 1/16/13.
//  Copyright (c) 2013 URBN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopPageViewController : UIViewController

@property (nonatomic, strong) NSString *department;

- (void)updateViewWithTitle:(NSString *)title;

@end

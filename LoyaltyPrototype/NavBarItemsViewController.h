//
//  NavBarItemsViewController.h
//  LoyaltyPrototype
//
//  Created by Jason Grandelli on 1/9/13.
//  Copyright (c) 2013 URBN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavBarItemsViewController : UIViewController

@property (nonatomic, strong) NSString *pageType;

- (void)updateInfo;

@end

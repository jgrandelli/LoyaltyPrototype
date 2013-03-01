//
//  AppDelegate.h
//  LoyaltyPrototype
//
//  Created by Jason Grandelli on 12/5/12.
//  Copyright (c) 2012 URBN. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@protocol MyAppDelegateDelegate <NSObject>

@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *viewController;

extern NSString *const FBSessionStateChangedNotification;

//- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI delegate:(id)delegate;

@end

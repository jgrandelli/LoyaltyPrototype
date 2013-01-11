//
//  AppDelegate.m
//  LoyaltyPrototype
//
//  Created by Jason Grandelli on 12/5/12.
//  Copyright (c) 2012 URBN. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"
#import "UIColor+ColorConstants.h"
#import "ProfileViewController.h"
#import "MenuViewController.h"
#import "NavBarItemsViewController.h"

@implementation AppDelegate

#pragma - Initialization.

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
	ProfileViewController *profileVC = [[ProfileViewController alloc] init];
	MenuViewController *menuVC = [[MenuViewController alloc] init];
	
    //UINavigationController *navigationController = [[UINavigationController alloc] init];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:profileVC];
    ViewController *revealController = [[ViewController alloc] initWithFrontViewController:navigationController
                                                           rearViewController:menuVC];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor neonGreen], UITextAttributeTextColor, nil];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes: attributes
                                                forState: UIControlStateNormal];
    
    self.viewController = revealController;
    
	
	self.window.rootViewController = self.viewController;
	[self.window makeKeyAndVisible];
	
    [self customizeAppearance];
    
    return YES;
}

- (void)customizeAppearance {
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackTranslucent];
}

#pragma - ZUUIRevealControllerDelegate Protocol.

- (BOOL)revealController:(ZUUIRevealController *)revealController shouldRevealRearViewController:(UIViewController *)rearViewController {
	return YES;
}

- (BOOL)revealController:(ZUUIRevealController *)revealController shouldHideRearViewController:(UIViewController *)rearViewController {
	return YES;
}

- (void)revealController:(ZUUIRevealController *)revealController willRevealRearViewController:(UIViewController *)rearViewController {
	NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)revealController:(ZUUIRevealController *)revealController didRevealRearViewController:(UIViewController *)rearViewController {
	NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)revealController:(ZUUIRevealController *)revealController willHideRearViewController:(UIViewController *)rearViewController {
	NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)revealController:(ZUUIRevealController *)revealController didHideRearViewController:(UIViewController *)rearViewController {
	NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)revealController:(ZUUIRevealController *)revealController willResignRearViewControllerPresentationMode:(UIViewController *)rearViewController {
	NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)revealController:(ZUUIRevealController *)revealController didResignRearViewControllerPresentationMode:(UIViewController *)rearViewController {
	NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)revealController:(ZUUIRevealController *)revealController willEnterRearViewControllerPresentationMode:(UIViewController *)rearViewController {
	NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)revealController:(ZUUIRevealController *)revealController didEnterRearViewControllerPresentationMode:(UIViewController *)rearViewController {
	NSLog(@"%@", NSStringFromSelector(_cmd));
}

@end

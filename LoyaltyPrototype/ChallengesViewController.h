//
//  ChallengesViewController.h
//  LoyaltyPrototype
//
//  Created by Jason Grandelli on 12/12/12.
//  Copyright (c) 2012 URBN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChallengeData.h"

@protocol ChallengesViewControllerDelegate <NSObject>

- (void)challengeSelectedWithData:(ChallengeData *)data;

@end

@interface ChallengesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) id delegate;

@end

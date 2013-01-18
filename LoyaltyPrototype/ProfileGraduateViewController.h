//
//  ProfileGraduateViewController.h
//  LoyaltyPrototype
//
//  Created by Jason Grandelli on 1/17/13.
//  Copyright (c) 2013 URBN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChallengeData.h"

@interface ProfileGraduateViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

- (id)initWithData:(ChallengeData *)data;

@end

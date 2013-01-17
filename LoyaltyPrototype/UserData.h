//
//  UserData.h
//  LoyaltyPrototype
//
//  Created by Jason Grandelli on 1/9/13.
//  Copyright (c) 2013 URBN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserData : NSObject

@property (nonatomic, strong) NSString *sessionKey;
@property (nonatomic, strong) NSString *handle;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *imgPath;
@property (nonatomic) int points;
@property (nonatomic, strong) NSString *formattedPoints;
@property (nonatomic, strong) NSString *currentLevel;
@property (nonatomic) int currentLevelGoal;
@property (nonatomic, strong) NSString *formattedCurrentLevelGoal;
@property (nonatomic, strong) NSString *nextLevel;
@property (nonatomic) int nextLevelGoal;
@property (nonatomic, strong) NSString *formattedNextLevelGoal;
@property (nonatomic) int pointsToGo;
@property (nonatomic, strong) NSString *formattedPointsToGo;
@property (nonatomic) CGFloat percentAchieved;
@property (nonatomic, strong) NSArray *feedArray;
@property (nonatomic, strong) NSString *userDataPath;

+ (id)sharedInstance;
- (void)parseUserData:(NSDictionary *)data;
- (void)retrieveInitialSessionKey;

@end

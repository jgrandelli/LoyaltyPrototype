//
//  ChallengeData.h
//  LoyaltyPrototype
//
//  Created by Jason Grandelli on 12/14/12.
//  Copyright (c) 2012 URBN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChallengeData : NSObject

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *iconFont;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic) int points;
@property (nonatomic, strong) NSString *pointsString;
@property (nonatomic) CGFloat completion;
@property (nonatomic, strong) NSArray *rulesArray;
@property (nonatomic) BOOL hasLeaderboard;
@property (nonatomic) BOOL locked;

- (id)initWithDictionary:(NSDictionary *)data;


@end

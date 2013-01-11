//
//  UserData.m
//  LoyaltyPrototype
//
//  Created by Jason Grandelli on 1/9/13.
//  Copyright (c) 2013 URBN. All rights reserved.
//

#import "UserData.h"

@implementation UserData

+ (id)sharedInstance {
    static UserData *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[UserData alloc] init];
    });
    
    return  __sharedInstance;
}

- (void)parseUserData:(NSDictionary *)data {
    for ( NSDictionary *dict in [data objectForKey:@"Nitro"] ) {
        if ( [dict objectForKey:@"Login"] ) self.sessionKey = [[dict objectForKey:@"Login"] objectForKey:@"sessionKey"];
        else if ( [dict objectForKey:@"userPreferences"] ) {
            NSArray *prefArray = [[dict objectForKey:@"userPreferences"] objectForKey:@"UserPreference"];
            for ( NSDictionary *prefDict in prefArray ) {
                if ( [[prefDict objectForKey:@"name"] isEqualToString:@"profile_name"] ) self.handle = [prefDict objectForKey:@"value"];
                else if ( [[prefDict objectForKey:@"name"] isEqualToString:@"gender"] ) self.gender = [prefDict objectForKey:@"value"];
                else if ( [[prefDict objectForKey:@"name"] isEqualToString:@"email"] ) self.email = [prefDict objectForKey:@"value"];
                else if ( [[prefDict objectForKey:@"name"] isEqualToString:@"profile_url"] ) self.imgPath = [prefDict objectForKey:@"value"];
            }
        }
        else if ( [dict objectForKey:@"Balance"] ) {
            self.userID = [[dict objectForKey:@"Balance"] objectForKey:@"userId"];
            self.points = [[[dict objectForKey:@"Balance"] objectForKey:@"points"] intValue];
            self.formattedPoints = [self formattedPointsFromInt:_points];
        }
        else if ( [[dict objectForKey:@"method"] isEqualToString:@"user.getLevel"] ) {
            NSDictionary *levelDict = [[[dict objectForKey:@"users"] objectForKey:@"User"] objectForKey:@"SiteLevel"];
            self.currentLevel = [levelDict objectForKey:@"description"];
            self.currentLevelGoal = [[levelDict objectForKey:@"points"] intValue];
            self.formattedCurrentLevelGoal = [self formattedPointsFromInt:_currentLevelGoal];
        }
        else if ( [[dict objectForKey:@"method"] isEqualToString:@"user.getNextLevel"] ) {
            NSDictionary *levelDict = [[[dict objectForKey:@"users"] objectForKey:@"User"] objectForKey:@"SiteLevel"];
            self.nextLevel = [levelDict objectForKey:@"description"];
            self.nextLevelGoal = [[levelDict objectForKey:@"points"] intValue];
            self.formattedNextLevelGoal = [self formattedPointsFromInt:_nextLevelGoal];
            self.pointsToGo = _nextLevelGoal - _points;
            self.formattedPointsToGo = [self formattedPointsFromInt:_pointsToGo];
            self.percentAchieved = (CGFloat)(_points - _currentLevelGoal)/(_nextLevelGoal - _currentLevelGoal);
        }
    }
}

- (NSString *)formattedPointsFromInt:(int)pointInt {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSString *formattedString = [formatter stringFromNumber:[NSNumber numberWithInt:pointInt]];
    
    return formattedString;
}

@end

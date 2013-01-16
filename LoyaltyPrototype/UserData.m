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

- (NSString *)userDataPath {
    return @"http://sandbox.bunchball.net/nitro/json?method=batch.run&methodFeed=%5B%22method=user.login%26apiKey=a06f6dbdb43f4c2293fa615576e4c7dc%26userID=16%22,%22method=user.getPreferences%26userId=16%22,%22method=user.getPointsBalance%26pointCategory=all%26includeYearlyCredits=false%26criteria=BALANCE%22,%22method=user.getLevel%22,%22method=user.getNextLevel%22,%22method=site.getActionFeed%26returncount=10%26showchallengescompleted=true%26preferences=profile_name%7Cprofile_url%26apiKey=a06f6dbdb43f4c2293fa615576e4c7dc%22%5D";
}

- (void)parseUserData:(NSDictionary *)data {
    
    NSMutableArray *activityFeed = [[NSMutableArray alloc] init];
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
            self.points = [[[dict objectForKey:@"Balance"] objectForKey:@"lifetimeBalance"] intValue];
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
        else if ( [[dict objectForKey:@"method"] isEqualToString:@"site.getActionFeed"] ) {
            for ( NSDictionary *feedItem in [[dict objectForKey:@"items"] objectForKey:@"entry"] ) {
                
                NSString *content = [feedItem objectForKey:@"content"];
                
                int ts = [[feedItem objectForKey:@"ts"] intValue];
                NSDate* date = [NSDate dateWithTimeIntervalSince1970:ts];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
                NSString *dateString = [dateFormatter stringFromDate:date];

                NSString *handle = @"";
                for ( NSDictionary *userDict in [[feedItem objectForKey:@"UserPreferences"] objectForKey:@"UserPreference"] ) {
                    if ( [[userDict objectForKey:@"name"] isEqualToString:@"profile_name"] ) {
                        handle = [[userDict objectForKey:@"value"] uppercaseString];
                    }
                }
                
                NSDictionary *dict = [[NSMutableDictionary alloc] init];
                [dict setValue:content forKey:@"content"];
                [dict setValue:dateString forKey:@"timestamp"];
                [dict setValue:handle forKey:@"handle"];
                
                [activityFeed addObject:dict];
            }
        }
    }
    
    self.feedArray = [NSArray arrayWithArray:activityFeed];
}

- (NSString *)formattedPointsFromInt:(int)pointInt {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSString *formattedString = [formatter stringFromNumber:[NSNumber numberWithInt:pointInt]];
    
    return formattedString;
}

@end
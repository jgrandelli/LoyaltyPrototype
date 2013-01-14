//
//  ChallengeData.m
//  LoyaltyPrototype
//
//  Created by Jason Grandelli on 12/14/12.
//  Copyright (c) 2012 URBN. All rights reserved.
//

#import "ChallengeData.h"

@implementation ChallengeData

- (id)initWithDictionary:(NSDictionary *)data {
	self = [super init];
	
	if (nil != self) {
        [self organizeDataWithDictionary:data];
	}
	
	return self;
}

- (void)organizeDataWithDictionary:(NSDictionary *)data {
    self.key = [[data objectForKey:@"name"] lowercaseString];
    self.key = [_key stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    self.title = [data objectForKey:@"name"];
    self.description = [data objectForKey:@"description"];
    self.points = [[data objectForKey:@"pointAward"] intValue];
    self.pointsString = [self formatedPointsFromInt:self.points];
    if ( ![[data objectForKey:@"canAchieveChallenge"] isEqual:@"true"] ) self.locked = YES;
    
    CGFloat rulesCompletion = [self calcutateCompletionWithDictionary:[data objectForKey:@"rules"]];
    CGFloat challengeCompletion = [[data objectForKey:@"completionCount"] floatValue];
    
    self.completion = challengeCompletion;
    if ( challengeCompletion == 0.0 ) self.completion = rulesCompletion;
    
    NSString *customDataString = [data objectForKey:@"customData"];
    NSArray *customDataArray = [customDataString componentsSeparatedByString:@","];
    NSMutableDictionary *customDataDictionary = [[NSMutableDictionary alloc] init];
    for ( int i = 0; i < [customDataArray count]; ++i ) {
        NSString *pair = [customDataArray objectAtIndex:i];
        NSUInteger colonInt = [pair rangeOfString:@":"].location;
        if ( colonInt != NSNotFound ) {
            NSString *key = [pair substringToIndex:colonInt];
            NSString *value = [pair substringFromIndex:colonInt + 1];
            
            [customDataDictionary setObject:value forKey:key];
        }
    }
    
    NSArray *entypo = @[@"profile", @"checkin", @"review"];
    NSDictionary *icons = @{@"instagram":@"", @"facebook":@"", @"twitter":@"", @"checkin":@"", @"profile":@"👤", @"review":@""};
    if ( [entypo containsObject:[customDataDictionary objectForKey:@"type"]] ) self.iconFont = @"Entypo";
    else self.iconFont = @"EntypoSocial";
    self.type = [customDataDictionary objectForKey:@"type"];
    self.icon = [icons objectForKey:self.type];
    
    if ( [[customDataDictionary objectForKey:@"leaderboard"] isEqual:@"YES"] ) self.hasLeaderboard = YES;
}

- (CGFloat)calcutateCompletionWithDictionary:(NSDictionary *)rulesDict {
    id rulesCollection = [rulesDict objectForKey:@"Rule"];

    CGFloat overallComplete = 0.0;
    NSMutableArray *rulesArray = [[NSMutableArray alloc] init];

    if ( [rulesCollection isKindOfClass:[NSArray class]] ) {
        for ( NSDictionary *rule in rulesCollection ) {
            int sortOrder = [[rule objectForKey:@"sortOrder"] intValue];

            CGFloat goal = [[rule objectForKey:@"goal"] floatValue];
            CGFloat achieved = [[rule objectForKey:@"achieved"] floatValue];
            CGFloat percentComplete = achieved / goal;
            if ( percentComplete > 1.0 ) percentComplete = 1.0;
            
            NSString *description = [rule objectForKey:@"description"];
            
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:[NSNumber numberWithInt:sortOrder] forKey:@"sortOrder"];
            [dict setObject:[NSNumber numberWithFloat:goal] forKey:@"goal"];
            [dict setObject:[NSNumber numberWithFloat:achieved] forKey:@"achieved"];
            [dict setObject:[NSNumber numberWithFloat:percentComplete] forKey:@"compPercent"];
            [dict setObject:description forKey:@"description"];
            
            [rulesArray addObject:dict];
            
            overallComplete += percentComplete;
        }
        
        overallComplete /= [rulesArray count];
    }
    else if ( [rulesCollection isKindOfClass:[NSDictionary class]] ) {
        CGFloat goal = [[rulesCollection objectForKey:@"goal"] floatValue];
        CGFloat achieved = [[rulesCollection objectForKey:@"achieved"] floatValue];
        CGFloat percentComplete = achieved / goal;
        if ( percentComplete > 1.0 ) percentComplete = 1.0;
        
        NSString *description = @"";
        if ( [rulesCollection objectForKey:@"description"] ) description = [rulesCollection objectForKey:@"description"];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:[NSNumber numberWithFloat:goal] forKey:@"goal"];
        [dict setObject:[NSNumber numberWithFloat:achieved] forKey:@"achieved"];
        [dict setObject:[NSNumber numberWithFloat:percentComplete] forKey:@"compPercent"];
        [dict setObject:description forKey:@"description"];
        
        [rulesArray addObject:dict];
        
        overallComplete = percentComplete;
    }
    
    self.rulesArray = [NSArray arrayWithArray:rulesArray];
    
    return overallComplete;
}

- (NSString *)formatedPointsFromInt:(int)pointInt {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSString *formattedString = [formatter stringFromNumber:[NSNumber numberWithInt:pointInt]];
    
    return formattedString;
}


@end

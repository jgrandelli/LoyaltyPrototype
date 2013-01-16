//
//  UIColor+ColorConstants.m
//  LoyaltyPrototype
//
//  Created by Jason Grandelli on 12/6/12.
//  Copyright (c) 2012 URBN. All rights reserved.
//

#import "UIColor+ColorConstants.h"

@implementation UIColor (ColorConstants)

+ (UIColor *)neonBlue {
    return [UIColor colorWithRed:0.161 green:0.949 blue:1.000 alpha:1.000];
}

+ (UIColor *)neonPink {
    return [UIColor colorWithRed:1.000 green:0.314 blue:0.894 alpha:1.000];
}

+ (UIColor *)neonGreen {
    return [UIColor colorWithRed:0.737 green:0.871 blue:0.000 alpha:1.000];
}

+ (UIColor *)lightNeonGreen {
    return [UIColor colorWithRed:0.737 green:0.871 blue:0.000 alpha:0.3];
}

+ (UIColor *)offWhite {
    return [UIColor colorWithRed:230.0/255.0 green:231.0/255.0 blue:232.0/255.0 alpha:1.0];
    //return [UIColor colorWithWhite:0.933 alpha:1.000];
}

@end

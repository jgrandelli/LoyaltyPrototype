//
//  UIFont+UrbanAdditions.m
//  UO
//
//  Created by Kyle Steelman on 1/4/13.
//  Copyright (c) 2013 Urban Outfitters. All rights reserved.
//

#import "UIFont+UrbanAdditions.h"

@implementation UIFont (UrbanAdditions)
+ (UIFont*)fontNamedFippsRegularWithSize:(float)fontSize{
    return [UIFont fontWithName:@"Fipps-Regular" size:fontSize];
}
+ (UIFont*)fontNamedLoRes9BoldOaklandWithSize:(float)fontSize{
    return [UIFont fontWithName:@"LoRes9OT-WideBoldAltOakland" size:fontSize];
}
+ (UIFont*)fontNamedLoRes12BoldOaklandWithSize:(float)fontSize{
    return [UIFont fontWithName:@"LoRes12OT-BoldAltOakland" size:fontSize];
}
+ (UIFont*)fontNamedLoRes15BoldOaklandWithSize:(float)fontSize{
    return [UIFont fontWithName:@"LoRes15OT-BoldAltOakland" size:fontSize];
}
+ (UIFont*)fontNamedLoRes22BoldOaklandWithSize:(float)fontSize{
    return [UIFont fontWithName:@"LoRes22OT-BoldOakland" size:fontSize];
}
+ (UIFont*)fontNamedSuperScriptWithSize:(float)fontSize{
    return [UIFont fontWithName:@"superscript" size:fontSize];
}
@end

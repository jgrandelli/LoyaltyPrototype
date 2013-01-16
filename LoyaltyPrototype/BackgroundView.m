//
//  BackgroundView.m
//  LoyaltyPrototype
//
//  Created by Jason Grandelli on 1/14/13.
//  Copyright (c) 2013 URBN. All rights reserved.
//

#import "BackgroundView.h"
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>

@implementation BackgroundView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    
    CGRect topRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width - 5.0, rect.size.height - 5.0);
    CGRect bottomRect = CGRectMake(rect.origin.x + 5.0, rect.origin.y + 5.0, rect.size.width - 5.0, rect.size.height - 5.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0].CGColor);
    CGContextFillRect(context, bottomRect);

    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0].CGColor);
    CGContextFillRect(context, topRect);
    
    CGRect strokeRect = CGRectInset(topRect, 1.0, 1.0);
    
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0].CGColor);
    CGContextSetLineWidth(context, 3.5);
    CGContextStrokeRect(context, strokeRect);
}

@end

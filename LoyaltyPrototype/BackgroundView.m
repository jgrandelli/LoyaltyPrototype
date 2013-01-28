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

@interface BackgroundView()

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIColor *borderColor;

@end

@implementation BackgroundView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.color = [UIColor whiteColor];
        self.borderColor = [UIColor blackColor];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame color:(UIColor *)color borderColor:(UIColor *)borderColor {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.color = color;
        self.borderColor = borderColor;
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    
    CGRect topRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width - 5.0, rect.size.height - 5.0);
    CGRect bottomRect = CGRectMake(rect.origin.x + 5.0, rect.origin.y + 5.0, rect.size.width - 5.0, rect.size.height - 5.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, _borderColor.CGColor);
    CGContextFillRect(context, bottomRect);

    CGContextSetFillColorWithColor(context, _color.CGColor);
    CGContextFillRect(context, topRect);
    
    CGRect strokeRect = CGRectInset(topRect, 1.0, 1.0);
    
    CGContextSetStrokeColorWithColor(context, _borderColor.CGColor);
    CGContextSetLineWidth(context, 3.5);
    CGContextStrokeRect(context, strokeRect);
}

@end

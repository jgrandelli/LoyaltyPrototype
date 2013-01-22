//
//  NavBarItemsViewController.m
//  LoyaltyPrototype
//
//  Created by Jason Grandelli on 1/9/13.
//  Copyright (c) 2013 URBN. All rights reserved.
//

#import "NavBarItemsViewController.h"
#import "UIColor+ColorConstants.h"
#import "UIFont+UrbanAdditions.h"
#import "UserData.h"

@interface NavBarItemsViewController ()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIView *progressBack;
@property (nonatomic, strong) UIView *progressBar;

@end

@implementation NavBarItemsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.userInteractionEnabled = NO;

    UIImage *backgroundImg = [UIImage imageNamed:@"navBarBackground"];
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:backgroundImg];
    [self.view addSubview:backgroundView];
    
    CGRect frame;
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 11.0, self.view.bounds.size.width, 0.0)];
    _nameLabel.textColor = [UIColor blackColor];
    _nameLabel.backgroundColor = [UIColor clearColor];
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    _nameLabel.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:18];
    _nameLabel.text = _pageName;
    [_nameLabel sizeToFit];
    frame = _nameLabel.frame;
    frame.origin.x = roundf(self.view.frame.size.width*.5 - frame.size.width*.5);
    _nameLabel.frame = frame;
    [self.view addSubview:_nameLabel];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(_nameLabel.frame.origin.x - 8.0, _nameLabel.frame.origin.y - 4.0, _nameLabel.frame.size.width + 16.0, _nameLabel.frame.size.height + 8.0)];
    backView.backgroundColor = [UIColor whiteColor];
    [self.view insertSubview:backView belowSubview:_nameLabel];
}

- (void)updateInfo {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

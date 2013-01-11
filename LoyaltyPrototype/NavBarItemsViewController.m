//
//  NavBarItemsViewController.m
//  LoyaltyPrototype
//
//  Created by Jason Grandelli on 1/9/13.
//  Copyright (c) 2013 URBN. All rights reserved.
//

#import "NavBarItemsViewController.h"
#import "UIColor+ColorConstants.h"
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
    
    CGRect frame;
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 0.0)];
    _nameLabel.textColor = [UIColor neonBlue];
    _nameLabel.backgroundColor = [UIColor clearColor];
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    _nameLabel.font = [UIFont boldSystemFontOfSize:16.0];
    frame = _nameLabel.frame;
    _nameLabel.text = @"";
    [_nameLabel sizeToFit];
    frame.size.height = _nameLabel.frame.size.height;
    _nameLabel.frame = frame;
    [self.view addSubview:_nameLabel];
    
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, frame.origin.y + frame.size.height, self.view.bounds.size.width, 0.0)];
    _statusLabel.textColor = [UIColor neonBlue];
    _statusLabel.backgroundColor = [UIColor clearColor];
    _statusLabel.textAlignment = NSTextAlignmentCenter;
    _statusLabel.font = [UIFont boldSystemFontOfSize:12.0];
    frame = _statusLabel.frame;
    _statusLabel.text = @"";
    [_statusLabel sizeToFit];
    frame.size.height = _statusLabel.frame.size.height;
    _statusLabel.frame = frame;
    [self.view addSubview:_statusLabel];
    
    self.progressBack = [[UIView alloc] initWithFrame:CGRectMake(0.0, 42.0, self.view.frame.size.width, 2.0)];
    _progressBack.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_progressBack];
    
    self.progressBar = [[UIView alloc] initWithFrame:CGRectMake(0.0, _progressBack.frame.origin.y, 0.0, 2.0)];
    _progressBar.backgroundColor = [UIColor neonGreen];
    [self.view addSubview:_progressBar];
}

- (void)updateInfo {
    UserData *userData = [UserData sharedInstance];
    
    CGRect frame;
    _nameLabel.frame = CGRectMake(0.0, 2.0, self.view.bounds.size.width, 0.0);
    frame = _nameLabel.frame;
    _nameLabel.text = [userData.handle uppercaseString];
    [_nameLabel sizeToFit];
    frame.size.height = _nameLabel.frame.size.height;
    _nameLabel.frame = frame;
    
    _statusLabel.frame = CGRectMake(0.0, frame.origin.y + frame.size.height, self.view.bounds.size.width, 0.0);
    frame = _statusLabel.frame;
    _statusLabel.text = [NSString stringWithFormat:@"%@: %@ points", userData.currentLevel, userData.formattedPoints];
    [_statusLabel sizeToFit];
    frame.size.height = _statusLabel.frame.size.height;
    _statusLabel.frame = frame;
    
    CGFloat progressWidth = _progressBack.frame.size.width * userData.percentAchieved;
    frame = _progressBar.frame;
    frame.size.width = progressWidth;
    _progressBar.frame = frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

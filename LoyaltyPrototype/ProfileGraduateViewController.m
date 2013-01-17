//
//  ProfileGraduateViewController.m
//  LoyaltyPrototype
//
//  Created by Jason Grandelli on 1/17/13.
//  Copyright (c) 2013 URBN. All rights reserved.
//

#import "ProfileGraduateViewController.h"
#import "BackgroundView.h"
#import "UIFont+UrbanAdditions.h"
#import "NavBarItemsViewController.h"
#import "UserData.h"
#import <AFNetworking.h>
#import <MBProgressHUD.h>
#import <QuartzCore/QuartzCore.h>

@interface ProfileGraduateViewController ()

@property (nonatomic, strong) ChallengeData *data;
@property (nonatomic, strong) UIView *compBar;
@property (nonatomic, strong) UIView *compBarBack;
@property (nonatomic, strong) UILabel *compBarLabel;

@end

@implementation ProfileGraduateViewController

#define MARGIN 15.0f
#define PADDING 10.0f

- (id)initWithData:(ChallengeData *)data {
	self = [super init];
	
	if (nil != self) {
        self.data = data;
	}
	
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    [self.navigationItem setHidesBackButton:YES];

    int i = (arc4random() % 9) + 1;
    NSString *patternName = [NSString stringWithFormat:@"Background%i", i];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:patternName]];
    
    CGFloat totalWidth = self.view.frame.size.width - MARGIN*2;
    
    BackgroundView *backView = [[BackgroundView alloc] initWithFrame:CGRectMake(MARGIN, self.navigationController.navigationBar.frame.size.height + MARGIN, totalWidth, 100.0)];
    [self.view addSubview:backView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, PADDING, 0.0, 0.0)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:16.0];
    titleLabel.text = _data.title;
    [titleLabel sizeToFit];
    [backView addSubview:titleLabel];
    
    self.compBarLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x + 5.0,
                                                               titleLabel.frame.origin.y + titleLabel.frame.size.height + 15.0,
                                                               0.0,
                                                               0.0)];
    _compBarLabel.backgroundColor = [UIColor clearColor];
    _compBarLabel.textColor = [UIColor whiteColor];
    _compBarLabel.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:13.0];
    int perc = _data.completion * 100;
    _compBarLabel.text = [NSString stringWithFormat:@"%i%% completed", perc];
    [_compBarLabel sizeToFit];
    [backView addSubview:_compBarLabel];
    
    self.compBar = [[UIView alloc] initWithFrame:CGRectMake(_compBarLabel.frame.origin.x - 5.0,
                                                            _compBarLabel.frame.origin.y - 5.0,
                                                            (totalWidth - PADDING*2 - 5.0) * _data.completion,
                                                            _compBarLabel.frame.size.height + 10.0)];
    _compBar.backgroundColor = [UIColor redColor];
    [backView insertSubview:_compBar belowSubview:_compBarLabel];
    
    self.compBarBack = [[UIView alloc] initWithFrame:CGRectMake(_compBar.frame.origin.x,
                                                                _compBar.frame.origin.y,
                                                                totalWidth - PADDING*2 - 5.0,
                                                                _compBar.frame.size.height)];
    _compBarBack.backgroundColor = [UIColor darkGrayColor];
    [backView insertSubview:_compBarBack belowSubview:_compBar];
    
    backView.frame = CGRectMake(MARGIN, self.navigationController.navigationBar.frame.size.height + MARGIN, totalWidth, _compBarBack.frame.origin.y + _compBarBack.frame.size.height + PADDING + 5.0);
    [backView setNeedsDisplay];

    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIImage *leftImg = [UIImage imageNamed:@"backBtn"];
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(10.0, 5.0, leftImg.size.width, leftImg.size.height);
    [leftButton setImage:leftImg forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    leftButton.tag = 1;
    [self.navigationController.navigationBar addSubview:leftButton];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    UIButton *btn = (UIButton *)[self.navigationController.navigationBar viewWithTag:1];
    [btn removeFromSuperview];
}

- (void)backBtnPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

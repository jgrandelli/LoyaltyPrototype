//
//  StatusViewController.m
//  LoyaltyPrototype
//
//  Created by Jason Grandelli on 12/6/12.
//  Copyright (c) 2012 URBN. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "StatusViewController.h"
#import "UIColor+ColorConstants.h"
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import <UIImageView+AFNetworking.h>
#import "UserData.h"
#import "NavBarItemsViewController.h"
#import "BackgroundView.h"
#import "UIFont+UrbanAdditions.h"

@interface StatusViewController()

@property (nonatomic, strong) NavBarItemsViewController *navBarItems;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *nextLevelLabel;
@property (nonatomic, strong) UIView *progressBack;
@property (nonatomic, strong) UIView *progressBar;
@property (nonatomic, strong) UILabel *progressPercentLabel;
@property (nonatomic, strong) UILabel *pointsToGoLabel;
@property (nonatomic, strong) UIScrollView *feedScroller;

@end

@implementation StatusViewController

#define MARGIN 15.0f

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"StatusBackground"]];

    self.navBarItems = [[NavBarItemsViewController alloc] init];
    _navBarItems.pageName = @"MYUO Status";
    [_navBarItems.view setFrame:self.navigationController.navigationBar.bounds];
    [self.navigationController.navigationBar addSubview:_navBarItems.view];
    
    if ([self.navigationController.parentViewController respondsToSelector:@selector(revealGesture:)] &&
        [self.navigationController.parentViewController respondsToSelector:@selector(revealToggle:)])
    {
        UIPanGestureRecognizer *navigationBarPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self.navigationController.parentViewController action:@selector(revealGesture:)];
		[self.navigationController.navigationBar addGestureRecognizer:navigationBarPanGestureRecognizer];
		
		
        UIImage *leftImg = [UIImage imageNamed:@"menuBtn"];
        UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.frame = CGRectMake(10.0, 5.0, leftImg.size.width, leftImg.size.height);
        [leftButton setImage:leftImg forState:UIControlStateNormal];
        [leftButton addTarget:self.navigationController.parentViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationController.navigationBar addSubview:leftButton];
	}

    UIImage *rightImg = [UIImage imageNamed:@"refreshBtn"];
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(self.view.frame.size.width - rightImg.size.width - 10.0, 5.0, rightImg.size.width, rightImg.size.height);
    [rightBtn setImage:rightImg forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:rightBtn];
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    NSURL *userURL = [NSURL URLWithString:[[UserData sharedInstance] userDataPath]];
    NSURLRequest *userReq = [NSURLRequest requestWithURL:userURL];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:userReq
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            JSON = [JSON objectForKey:@"Nitro"];
                                                                                            UserData *userData = [UserData sharedInstance];
                                                                                            [userData parseUserData:JSON];
                                                                                            [self updateNavBarItems];
                                                                                            [self setupProfile];
                                                                                        }
                                                                                        failure:nil];
    [operation start];
}

- (void)refreshData {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSURL *userURL = [NSURL URLWithString:[[UserData sharedInstance] userDataPath]];
    NSURLRequest *userReq = [NSURLRequest requestWithURL:userURL];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:userReq
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            JSON = [JSON objectForKey:@"Nitro"];
                                                                                            UserData *userData = [UserData sharedInstance];
                                                                                            [userData parseUserData:JSON];
                                                                                            [self updateNavBarItems];
                                                                                            [self updateProfile];
                                                                                        }
                                                                                        failure:nil];
    [operation start];
}

- (void)updateNavBarItems {
    [_navBarItems updateInfo];
}

- (void)updateProfile {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    UserData *userData = [UserData sharedInstance];

    _nameLabel.frame = CGRectMake(_nameLabel.frame.origin.x, _nameLabel.frame.origin.y, 0.0, 0.0);
    NSString *nameLabelText = nil;
    if ( userData.firstName ) nameLabelText = [NSString stringWithFormat:@"AKA: %@ %@\n%@", userData.firstName, userData.lastName, userData.currentLevel];
    else nameLabelText = userData.currentLevel;
    _nameLabel.text = nameLabelText;
    [_nameLabel sizeToFit];
    
    NSString *nextLevelString = nil;
    if ( userData.percentAchieved < 1.0 ) nextLevelString = [NSString stringWithFormat:@"Next Level: %@ %@ points", userData.nextLevel, userData.formattedNextLevelGoal];
    else nextLevelString = userData.nextLevel;
    _nextLevelLabel.frame = CGRectMake(_nextLevelLabel.frame.origin.x, _nextLevelLabel.frame.origin.y, _progressBack.frame.size.width, 0.0);
    _nextLevelLabel.text = nextLevelString;
    CGRect frame = _nextLevelLabel.frame;
    [_nextLevelLabel sizeToFit];
    frame.size.height = _nextLevelLabel.frame.size.height;
    _nextLevelLabel.frame = frame;

    frame = _progressBar.frame;
    frame.size.width = _progressBack.frame.size.width * userData.percentAchieved;
    _progressBar.frame = frame;
    
    _progressPercentLabel.frame = CGRectMake(_progressPercentLabel.frame.origin.x, _progressPercentLabel.frame.origin.y, 0.0, 0.0);
    int percValue = userData.percentAchieved * 100;
    _progressPercentLabel.text = [NSString stringWithFormat:@"%i%%", percValue];
    [_progressPercentLabel sizeToFit];
    
    _pointsToGoLabel.text = [NSString stringWithFormat:@"%@ more to go", userData.formattedPointsToGo];
    
    UIView *oldHolder = [_feedScroller viewWithTag:100];
    
    UIView *feedHolder = [[UIView alloc] initWithFrame:CGRectZero];
    CGFloat yPos = 10.0;
    for ( NSDictionary *feedItem in userData.feedArray ) {
        NSString *content = [NSString stringWithFormat:@"%@: %@", [feedItem objectForKey:@"handle"], [feedItem objectForKey:@"content"]];
        NSMutableAttributedString *attString=[[NSMutableAttributedString alloc] initWithString:content];
        
        NSRange handleRange = [content rangeOfString:[feedItem objectForKey:@"handle"]];
        UIFont *boldFont = [UIFont fontNamedLoRes9BoldOaklandWithSize:12.0];
        UIColor *boldColor = [UIColor blueColor];
        [attString addAttribute:NSFontAttributeName value:boldFont range:handleRange];
        [attString addAttribute:NSForegroundColorAttributeName value:boldColor range:handleRange];
        
        UILabel *feedLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, yPos, oldHolder.frame.size.width - 20.0, 0.0)];
        feedLabel.backgroundColor = [UIColor clearColor];
        feedLabel.textColor = [UIColor blackColor];
        feedLabel.numberOfLines = 0;
        feedLabel.lineBreakMode = NSLineBreakByWordWrapping;
        feedLabel.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:12.0];
        feedLabel.attributedText = attString;
        
        [feedLabel sizeToFit];
        [feedHolder addSubview:feedLabel];
        
        yPos += roundf(8.0 + feedLabel.frame.size.height);
    }
    
    feedHolder.frame = CGRectMake(0.0, 0.0, oldHolder.frame.size.width, yPos + 10.0);
    [oldHolder removeFromSuperview];
    feedHolder.tag = 100;
    [_feedScroller addSubview:feedHolder];
    _feedScroller.contentSize = feedHolder.frame.size;
    
    [self.view addSubview:_feedScroller];

}

- (void)setupProfile {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    UserData *userData = [UserData sharedInstance];
    
    CGFloat totalWidth = self.view.frame.size.width - MARGIN*2;
    
    BackgroundView *backView = [[BackgroundView alloc] initWithFrame:CGRectMake(MARGIN, roundf(navBar.frame.size.height + MARGIN), totalWidth, 95.0)];
    [self.view addSubview:backView];
    
    UIImageView *profileImgView = [[UIImageView alloc] initWithFrame:CGRectMake(roundf(backView.frame.origin.x + 10.0), roundf(backView.frame.origin.y + 10.0), 70.0, 70.0)];
    [profileImgView setImageWithURL:[NSURL URLWithString:userData.imgPath]];
    profileImgView.layer.borderWidth = 2;
    profileImgView.layer.borderColor = [UIColor blackColor].CGColor;
    [self.view addSubview:profileImgView];
    
    UILabel *handleLabel = [[UILabel alloc] initWithFrame:CGRectMake(roundf(profileImgView.frame.origin.x + profileImgView.frame.size.width + 10.0),
                                                                     profileImgView.frame.origin.y,
                                                                     100.0, 40.0)];
    handleLabel.backgroundColor = [UIColor clearColor];
    handleLabel.textColor = [UIColor blackColor];
    handleLabel.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:18.0];
    handleLabel.text = [userData.handle uppercaseString];
    [handleLabel sizeToFit];
    CGRect frame = handleLabel.frame;
    frame.origin.y = roundf(profileImgView.frame.origin.y - 2.0);
    handleLabel.frame = frame;
    [self.view addSubview:handleLabel];
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(handleLabel.frame.origin.x,
                                                                   roundf(handleLabel.frame.origin.y + handleLabel.frame.size.height + 2.0),
                                                                   400.0, 40.0)];
    _nameLabel.backgroundColor = [UIColor clearColor];
    _nameLabel.numberOfLines = 2;
    _nameLabel.textColor = [UIColor blackColor];
    _nameLabel.font = [UIFont fontNamedLoRes15BoldOaklandWithSize:15.0];
    NSString *nameLabelText = nil;
    if ( userData.firstName ) nameLabelText = [NSString stringWithFormat:@"AKA: %@ %@\n%@", userData.firstName, userData.lastName, userData.currentLevel];
    else nameLabelText = userData.currentLevel;
    _nameLabel.text = nameLabelText;
    [_nameLabel sizeToFit];
    [self.view addSubview:_nameLabel];
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(_nameLabel.frame.origin.x,
                                                                   roundf(profileImgView.frame.origin.y + profileImgView.frame.size.height),
                                                                   200.0, 40.0)];
    dateLabel.backgroundColor = [UIColor clearColor];
    dateLabel.textColor = [UIColor blackColor];
    dateLabel.font = [UIFont fontNamedLoRes22BoldOaklandWithSize:14.0];
    dateLabel.text = @"Member since 2012";
    [dateLabel sizeToFit];
    frame = dateLabel.frame;
    frame.origin.y = roundf(profileImgView.frame.origin.y + profileImgView.frame.size.height - dateLabel.frame.size.height + 2.0);
    dateLabel.frame = frame;
    [self.view addSubview:dateLabel];
    
    CGFloat yPos = roundf(backView.frame.origin.y + backView.frame.size.height + 10.0);
    
    backView = [[BackgroundView alloc] initWithFrame:CGRectMake(MARGIN, yPos, totalWidth, 95.0)];
    [self.view addSubview:backView];
    
    NSString *nextLevelString = nil;
    if ( userData.percentAchieved < 1.0 ) nextLevelString = [NSString stringWithFormat:@"Next Level: %@ %@ points", userData.nextLevel, userData.formattedNextLevelGoal];
    else nextLevelString = userData.nextLevel;
    
    self.nextLevelLabel = [[UILabel alloc] initWithFrame:CGRectMake(roundf(backView.frame.origin.x + 10.0),
                                                                        roundf(backView.frame.origin.y + 10.0),
                                                                        backView.frame.size.width - 25.0, 40.0)];
    _nextLevelLabel.backgroundColor = [UIColor clearColor];
    _nextLevelLabel.font = [UIFont fontNamedLoRes15BoldOaklandWithSize:14.0];
    _nextLevelLabel.textColor = [UIColor blackColor];
    _nextLevelLabel.numberOfLines = 0;
    _nextLevelLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _nextLevelLabel.text = nextLevelString;
    frame = _nextLevelLabel.frame;
    [_nextLevelLabel sizeToFit];
    frame.size.height = _nextLevelLabel.frame.size.height;
    _nextLevelLabel.frame = frame;
    [self.view addSubview:_nextLevelLabel];
    
    self.progressBack = [[UIView alloc] initWithFrame:CGRectMake(_nextLevelLabel.frame.origin.x,
                                                                    roundf(_nextLevelLabel.frame.origin.y + _nextLevelLabel.frame.size.height + 4.0),
                                                                    backView.frame.size.width - 25.0, 7.0)];
    _progressBack.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_progressBack];
    
    CGFloat progressWidth = _progressBack.frame.size.width * userData.percentAchieved;
    
    self.progressBar = [[UIView alloc] initWithFrame:CGRectMake(_progressBack.frame.origin.x,
                                                                   _progressBack.frame.origin.y,
                                                                   progressWidth, _progressBack.frame.size.height)];
    _progressBar.backgroundColor = [UIColor redColor];
    [self.view addSubview:_progressBar];
    
    self.progressPercentLabel = [[UILabel alloc] initWithFrame:CGRectMake(_nextLevelLabel.frame.origin.x,
                                                                              roundf(_progressBack.frame.origin.y + _progressBack.frame.size.height + 4.0),
                                                                          100.0, 40.0)];
    _progressPercentLabel.backgroundColor = [UIColor clearColor];
    _progressPercentLabel.textColor = [UIColor blackColor];
    _progressPercentLabel.font = [UIFont fontNamedLoRes15BoldOaklandWithSize:14.0];
    int percValue = userData.percentAchieved * 100;
    _progressPercentLabel.text = [NSString stringWithFormat:@"%i%%", percValue];
    [_progressPercentLabel sizeToFit];
    [self.view addSubview:_progressPercentLabel];
    
    self.pointsToGoLabel = [[UILabel alloc] initWithFrame:CGRectMake(_nextLevelLabel.frame.origin.x,
                                                                         _progressPercentLabel.frame.origin.y,
                                                                         backView.frame.size.width - 25.0, _progressPercentLabel.frame.size.height)];
    _pointsToGoLabel.backgroundColor = [UIColor clearColor];
    _pointsToGoLabel.textAlignment = NSTextAlignmentRight;
    _pointsToGoLabel.textColor = [UIColor blackColor];
    _pointsToGoLabel.font = _progressPercentLabel.font;
    _pointsToGoLabel.text = [NSString stringWithFormat:@"%@ more to go", userData.formattedPointsToGo];
    [self.view addSubview:_pointsToGoLabel];
    
    backView.frame = CGRectMake(MARGIN, yPos, totalWidth, _pointsToGoLabel.frame.origin.y + _pointsToGoLabel.frame.size.height + 15.0 - yPos);
    
    yPos = backView.frame.origin.y + backView.frame.size.height + 10.0;
    
    backView = [[BackgroundView alloc] initWithFrame:CGRectMake(MARGIN, yPos, totalWidth, self.view.frame.size.height - yPos - 10.0)];
    [self.view addSubview:backView];
    
    UILabel *stalkingLabel = [[UILabel alloc] initWithFrame:CGRectMake(backView.frame.origin.x + 10.0,
                                                                       backView.frame.origin.y + 10.0,
                                                                       1.0, 1.0)];
    stalkingLabel.backgroundColor = [UIColor clearColor];
    stalkingLabel.textColor = [UIColor blackColor];
    stalkingLabel.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:14.0];
    stalkingLabel.text = @"Activity feed";
    [stalkingLabel sizeToFit];
    [self.view addSubview:stalkingLabel];

    UIView *blackLine = [[UIView alloc] initWithFrame:CGRectMake(backView.frame.origin.x,
                                                                 stalkingLabel.frame.origin.y + stalkingLabel.frame.size.height + 5.0,
                                                                 backView.frame.size.width - 5.0, 2.0)];
    blackLine.backgroundColor = [UIColor blackColor];
    [self.view addSubview:blackLine];
    
    self.feedScroller = [[UIScrollView alloc] initWithFrame:CGRectMake(blackLine.frame.origin.x,
                                                                       blackLine.frame.origin.y + 1,
                                                                       blackLine.frame.size.width,
                                                                       backView.frame.size.height - (blackLine.frame.origin.y - backView.frame.origin.y) - 9.0)];

    UIView *feedHolder = [[UIView alloc] initWithFrame:CGRectZero];
    yPos = 10.0;
    for ( NSDictionary *feedItem in userData.feedArray ) {
        NSString *content = [NSString stringWithFormat:@"%@: %@", [feedItem objectForKey:@"handle"], [feedItem objectForKey:@"content"]];
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:content];
        
        NSRange handleRange = [content rangeOfString:[feedItem objectForKey:@"handle"]];
        UIFont *boldFont = [UIFont fontNamedLoRes9BoldOaklandWithSize:12.0];
        UIColor *boldColor = [UIColor blueColor];
        [attString addAttribute:NSFontAttributeName value:boldFont range:handleRange];
        [attString addAttribute:NSForegroundColorAttributeName value:boldColor range:handleRange];
        
        UILabel *feedLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, yPos, backView.frame.size.width - 25.0, 0.0)];
        feedLabel.backgroundColor = [UIColor clearColor];
        feedLabel.textColor = [UIColor blackColor];
        feedLabel.numberOfLines = 0;
        feedLabel.lineBreakMode = NSLineBreakByWordWrapping;
        feedLabel.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:12.0];
        feedLabel.attributedText = attString;
        
        [feedLabel sizeToFit];
        [feedHolder addSubview:feedLabel];
        
        yPos += 8.0 + feedLabel.frame.size.height;
    }
    
    feedHolder.frame = CGRectMake(0.0, 0.0, backView.frame.size.width - 5.0, yPos + 10.0);
    feedHolder.tag = 100;
    [_feedScroller addSubview:feedHolder];
    _feedScroller.contentSize = feedHolder.frame.size;
    
    [self.view addSubview:_feedScroller];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
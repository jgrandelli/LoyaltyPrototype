//
//  ProfileViewController.m
//  LoyaltyPrototype
//
//  Created by Jason Grandelli on 12/6/12.
//  Copyright (c) 2012 URBN. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ProfileViewController.h"
#import "UIColor+ColorConstants.h"
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import <UIImageView+AFNetworking.h>
#import "UserData.h"
#import "NavBarItemsViewController.h"

@interface ProfileViewController()

@property (nonatomic, strong) NavBarItemsViewController *navBarItems;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *nextLevelLabel;
@property (nonatomic, strong) UIView *progressBack;
@property (nonatomic, strong) UIView *progressBar;
@property (nonatomic, strong) UILabel *progressPercentLabel;
@property (nonatomic, strong) UILabel *pointsToGoLabel;
@property (nonatomic, strong) UIScrollView *feedScroller;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    
    if ([self.navigationController.parentViewController respondsToSelector:@selector(revealGesture:)] &&
        [self.navigationController.parentViewController respondsToSelector:@selector(revealToggle:)])
    {
        UIPanGestureRecognizer *navigationBarPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self.navigationController.parentViewController action:@selector(revealGesture:)];
		[self.navigationController.navigationBar addGestureRecognizer:navigationBarPanGestureRecognizer];
		
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"\u2630" style:UIBarButtonItemStylePlain target:self.navigationController.parentViewController action:@selector(revealToggle:)];
        [self.navigationItem.leftBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                       [UIFont fontWithName:@"Entypo" size:50.0], UITextAttributeFont,
                                                                       [UIColor neonGreen], UITextAttributeTextColor, nil] forState:UIControlStateNormal];
	}
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"🔁" style:UIBarButtonItemStylePlain target:self action:@selector(refreshData)];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                   [UIFont fontWithName:@"Entypo" size:45.0], UITextAttributeFont,
                                                                   [UIColor neonGreen], UITextAttributeTextColor, nil] forState:UIControlStateNormal];
    
    
    self.navBarItems = [[NavBarItemsViewController alloc] init];
    [_navBarItems.view setFrame:self.navigationController.navigationBar.bounds];
    [self.navigationController.navigationBar addSubview:_navBarItems.view];
    
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
    
    _nextLevelLabel.frame = CGRectMake(_nextLevelLabel.frame.origin.x, _nextLevelLabel.frame.origin.y, 0.0, 0.0);
    _nextLevelLabel.text = [NSString stringWithFormat:@"Next Level: %@ %@ points", userData.nextLevel, userData.formattedNextLevelGoal];
    [_nextLevelLabel sizeToFit];

    CGRect frame = _progressBar.frame;
    frame.size.width = _progressBack.frame.size.width * userData.percentAchieved;
    _progressBar.frame = frame;
    
    _progressPercentLabel.frame = CGRectMake(_progressPercentLabel.frame.origin.x, _progressPercentLabel.frame.origin.y, 0.0, 0.0);
    int percValue = userData.percentAchieved * 100;
    _progressPercentLabel.text = [NSString stringWithFormat:@"%i%%", percValue];
    [_progressPercentLabel sizeToFit];
    
    _pointsToGoLabel.text = [NSString stringWithFormat:@"%@ more to go", userData.formattedPointsToGo];
    
    UIView *oldHolder = [_feedScroller viewWithTag:100];
    [oldHolder removeFromSuperview];
    
    UIView *feedHolder = [[UIView alloc] initWithFrame:CGRectZero];
    CGFloat yPos = 10.0;
    for ( NSDictionary *feedItem in userData.feedArray ) {
        NSString *content = [NSString stringWithFormat:@"%@: %@", [feedItem objectForKey:@"handle"], [feedItem objectForKey:@"content"]];
        NSMutableAttributedString *attString=[[NSMutableAttributedString alloc] initWithString:content];
        
        NSRange handleRange = [content rangeOfString:[feedItem objectForKey:@"handle"]];
        UIFont *boldFont = [UIFont boldSystemFontOfSize:12.0];
        UIColor *boldColor = [UIColor neonGreen];
        [attString addAttribute:NSFontAttributeName value:boldFont range:handleRange];
        [attString addAttribute:NSForegroundColorAttributeName value:boldColor range:handleRange];
        
        UILabel *feedLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, yPos, _feedScroller.frame.size.width - 20.0, 0.0)];
        feedLabel.backgroundColor = [UIColor clearColor];
        feedLabel.textColor = [UIColor offWhite];
        feedLabel.numberOfLines = 0;
        feedLabel.lineBreakMode = NSLineBreakByWordWrapping;
        feedLabel.font = [UIFont systemFontOfSize:12.0];
        feedLabel.textColor = [UIColor offWhite];
        feedLabel.attributedText = attString;
        
        [feedLabel sizeToFit];
        [feedHolder addSubview:feedLabel];
        
        yPos += 8.0 + feedLabel.frame.size.height;
    }
    feedHolder.tag = 100;
    feedHolder.frame = CGRectMake(0.0, 0.0, _feedScroller.frame.size.width, yPos + 10.0);
    [_feedScroller addSubview:feedHolder];
    _feedScroller.contentSize = feedHolder.frame.size;
    
    [self.view addSubview:_feedScroller];

}

- (void)setupProfile {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    UserData *userData = [UserData sharedInstance];
    
    UIImageView *profileImgView = [[UIImageView alloc] initWithFrame:CGRectMake(15.0, navBar.frame.size.height + 15.0, 70.0, 70.0)];
    [profileImgView setImageWithURL:[NSURL URLWithString:userData.imgPath]];
    profileImgView.layer.borderWidth = 3;
    profileImgView.layer.borderColor = [UIColor offWhite].CGColor;
    [self.view addSubview:profileImgView];
    
    UILabel *handleLabel = [[UILabel alloc] initWithFrame:CGRectMake(profileImgView.frame.origin.x + profileImgView.frame.size.width + 10.0,
                                                                     profileImgView.frame.origin.y,
                                                                     100.0, 40.0)];
    handleLabel.backgroundColor = [UIColor clearColor];
    handleLabel.textColor = [UIColor neonBlue];handleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    handleLabel.text = userData.handle;
    [handleLabel sizeToFit];
    CGRect frame = handleLabel.frame;
    frame.origin.y = profileImgView.frame.origin.y - 2.0;
    handleLabel.frame = frame;
    [self.view addSubview:handleLabel];
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(handleLabel.frame.origin.x,
                                                                   handleLabel.frame.origin.y + handleLabel.frame.size.height + 2.0,
                                                                   400.0, 40.0)];
    _nameLabel.backgroundColor = [UIColor clearColor];
    _nameLabel.numberOfLines = 2;
    _nameLabel.textColor = [UIColor neonBlue];
    _nameLabel.font = [UIFont systemFontOfSize:13.0];
    NSString *nameLabelText = nil;
    if ( userData.firstName ) nameLabelText = [NSString stringWithFormat:@"AKA: %@ %@\n%@", userData.firstName, userData.lastName, userData.currentLevel];
    else nameLabelText = userData.currentLevel;
    _nameLabel.text = nameLabelText;
    [_nameLabel sizeToFit];
    [self.view addSubview:_nameLabel];
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(_nameLabel.frame.origin.x,
                                                                   profileImgView.frame.origin.y + profileImgView.frame.size.height,
                                                                   200.0, 40.0)];
    dateLabel.backgroundColor = [UIColor clearColor];
    dateLabel.textColor = [UIColor neonBlue];
    dateLabel.font = [UIFont italicSystemFontOfSize:10.0];
    dateLabel.text = @"Member since 1983";
    [dateLabel sizeToFit];
    frame = dateLabel.frame;
    frame.origin.y = profileImgView.frame.origin.y + profileImgView.frame.size.height - dateLabel.frame.size.height + 2.0;
    dateLabel.frame = frame;
    [self.view addSubview:dateLabel];
    
    self.nextLevelLabel = [[UILabel alloc] initWithFrame:CGRectMake(profileImgView.frame.origin.x,
                                                                        profileImgView.frame.origin.y + profileImgView.frame.size.height + 25.0,
                                                                        self.view.bounds.size.width - 30.0, 40.0)];
    _nextLevelLabel.backgroundColor = [UIColor clearColor];
    _nextLevelLabel.font = [UIFont systemFontOfSize:13.0];
    _nextLevelLabel.textColor = [UIColor offWhite];
    _nextLevelLabel.text = [NSString stringWithFormat:@"Next Level: %@ %@ points", userData.nextLevel, userData.formattedNextLevelGoal];
    [_nextLevelLabel sizeToFit];
    [self.view addSubview:_nextLevelLabel];
    
    self.progressBack = [[UIView alloc] initWithFrame:CGRectMake(profileImgView.frame.origin.x,
                                                                    _nextLevelLabel.frame.origin.y + _nextLevelLabel.frame.size.height + 2.0,
                                                                    self.view.bounds.size.width - 30.0, 7.0)];
    _progressBack.backgroundColor = [UIColor offWhite];
    [self.view addSubview:_progressBack];
    
    CGFloat progressWidth = _progressBack.frame.size.width * userData.percentAchieved;
    
    self.progressBar = [[UIView alloc] initWithFrame:CGRectMake(_progressBack.frame.origin.x,
                                                                   _progressBack.frame.origin.y,
                                                                   progressWidth, _progressBack.frame.size.height)];
    _progressBar.backgroundColor = [UIColor neonGreen];
    [self.view addSubview:_progressBar];
    
    self.progressPercentLabel = [[UILabel alloc] initWithFrame:CGRectMake(_nextLevelLabel.frame.origin.x,
                                                                              _progressBack.frame.origin.y + _progressBack.frame.size.height + 2.0,
                                                                          100.0, 40.0)];
    _progressPercentLabel.backgroundColor = [UIColor clearColor];
    _progressPercentLabel.textColor = [UIColor offWhite];
    _progressPercentLabel.font = [UIFont systemFontOfSize:12.0];
    int percValue = userData.percentAchieved * 100;
    _progressPercentLabel.text = [NSString stringWithFormat:@"%i%%", percValue];
    [_progressPercentLabel sizeToFit];
    [self.view addSubview:_progressPercentLabel];
    
    self.pointsToGoLabel = [[UILabel alloc] initWithFrame:CGRectMake(_nextLevelLabel.frame.origin.x,
                                                                         _progressPercentLabel.frame.origin.y,
                                                                         self.view.bounds.size.width - 30.0, _progressPercentLabel.frame.size.height)];
    _pointsToGoLabel.backgroundColor = [UIColor clearColor];
    _pointsToGoLabel.textAlignment = NSTextAlignmentRight;
    _pointsToGoLabel.textColor = [UIColor offWhite];
    _pointsToGoLabel.font = _progressPercentLabel.font;
    _pointsToGoLabel.text = [NSString stringWithFormat:@"%@ more to go", userData.formattedPointsToGo];
    [self.view addSubview:_pointsToGoLabel];
    
    UIView *greenLine = [[UIView alloc] initWithFrame:CGRectMake(profileImgView.frame.origin.x,
                                                                 _pointsToGoLabel.frame.origin.y + _pointsToGoLabel.frame.size.height + 30.0,
                                                                 _progressBack.frame.size.width, 1.0)];
    greenLine.backgroundColor = [UIColor neonGreen];
    greenLine.alpha = 0.3;
    [self.view addSubview:greenLine];

    
    UILabel *mailIcon = [[UILabel alloc] initWithFrame:CGRectMake(greenLine.frame.origin.x + 3.0,
                                                                  greenLine.frame.origin.y - 7.0,
                                                                  40.0, 40.0)];
    mailIcon.backgroundColor = [UIColor clearColor];
    mailIcon.font = [UIFont fontWithName:@"Entypo" size:50.0];
    mailIcon.textColor = [UIColor neonGreen];
    mailIcon.text = @"💥";
    [mailIcon sizeToFit];
    [self.view addSubview:mailIcon];
    
    UILabel *mailLabel = [[UILabel alloc] initWithFrame:CGRectMake(mailIcon.frame.origin.x + mailIcon.frame.size.width + 5.0,
                                                                   roundf(mailIcon.center.y) - 10.0,
                                                                   40.0, 40.0)];
    mailLabel.backgroundColor = [UIColor clearColor];
    mailLabel.textColor = [UIColor offWhite];
    mailLabel.font = [UIFont systemFontOfSize:14.0];
    mailLabel.text = @"You have 3 new messages!";
    [mailLabel sizeToFit];
    [self.view addSubview:mailLabel];
    
    greenLine = [[UIView alloc] initWithFrame:CGRectMake(profileImgView.frame.origin.x,
                                                                 _pointsToGoLabel.frame.origin.y + _pointsToGoLabel.frame.size.height + 65.0,
                                                                 _progressBack.frame.size.width, 1.0)];
    greenLine.backgroundColor = [UIColor neonGreen];
    greenLine.alpha = 0.3;
    [self.view addSubview:greenLine];

    
    UILabel *stalkingLabel = [[UILabel alloc] initWithFrame:CGRectMake(greenLine.frame.origin.x,
                                                                       greenLine.frame.origin.y + 40.0,
                                                                       1.0, 1.0)];
    stalkingLabel.backgroundColor = [UIColor clearColor];
    stalkingLabel.textColor = [UIColor offWhite];
    stalkingLabel.font = [UIFont systemFontOfSize:14.0];
    stalkingLabel.text = @"You are stalking 10 friends...";
    [stalkingLabel sizeToFit];
    [self.view addSubview:stalkingLabel];
    
    greenLine = [[UIView alloc] initWithFrame:CGRectMake(greenLine.frame.origin.x,
                                                         stalkingLabel.frame.origin.y + stalkingLabel.frame.size.height + 2.0,
                                                         greenLine.frame.size.width, 1.0)];
    greenLine.backgroundColor = [UIColor neonGreen];
    greenLine.alpha = 0.3;
    [self.view addSubview:greenLine];
    
    self.feedScroller = [[UIScrollView alloc] initWithFrame:CGRectMake(greenLine.frame.origin.x,
                                                                       greenLine.frame.origin.y + 1,
                                                                       greenLine.frame.size.width,
                                                                       self.view.frame.size.height - greenLine.frame.origin.y - 1)];
    UIView *feedHolder = [[UIView alloc] initWithFrame:CGRectZero];
    CGFloat yPos = 10.0;
    for ( NSDictionary *feedItem in userData.feedArray ) {
        NSString *content = [NSString stringWithFormat:@"%@: %@", [feedItem objectForKey:@"handle"], [feedItem objectForKey:@"content"]];
        NSMutableAttributedString *attString=[[NSMutableAttributedString alloc] initWithString:content];

        NSRange handleRange = [content rangeOfString:[feedItem objectForKey:@"handle"]];
        UIFont *boldFont = [UIFont boldSystemFontOfSize:12.0];
        UIColor *boldColor = [UIColor neonGreen];
        [attString addAttribute:NSFontAttributeName value:boldFont range:handleRange];
        [attString addAttribute:NSForegroundColorAttributeName value:boldColor range:handleRange];
        
        UILabel *feedLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, yPos, greenLine.frame.size.width - 20.0, 0.0)];
        feedLabel.backgroundColor = [UIColor clearColor];
        feedLabel.textColor = [UIColor offWhite];
        feedLabel.numberOfLines = 0;
        feedLabel.lineBreakMode = NSLineBreakByWordWrapping;
        feedLabel.font = [UIFont systemFontOfSize:12.0];
        feedLabel.textColor = [UIColor offWhite];
        feedLabel.attributedText = attString;
        
        [feedLabel sizeToFit];
        [feedHolder addSubview:feedLabel];
        
        yPos += 8.0 + feedLabel.frame.size.height;
    }
    
    feedHolder.frame = CGRectMake(0.0, 0.0, greenLine.frame.size.width, yPos + 10.0);
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
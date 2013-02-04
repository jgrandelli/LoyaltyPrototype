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
#import "ChallengeData.h"
#import "ChallengeDetailViewController.h"

@interface StatusViewController()

@property (nonatomic, strong) NavBarItemsViewController *navBarItems;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *nextLevelLabel;
@property (nonatomic, strong) UIView *progressBack;
@property (nonatomic, strong) UIView *progressBar;
@property (nonatomic, strong) UILabel *progressPercentLabel;
@property (nonatomic, strong) UILabel *pointsToGoLabel;
@property (nonatomic, strong) UIScrollView *feedScroller;
@property (nonatomic, strong) UILabel *friendsLabel;
@property (nonatomic, strong) UIScrollView *badgeScroller;
@property (nonatomic, strong) NSMutableArray *challengesArray;
@property (nonatomic, strong) UIView *collectionView;
@property (nonatomic, strong) BackgroundView *collectionBack;
@property (nonatomic, strong) UILabel *tapLabel;
@property (nonatomic, strong) UIButton *challengeInfoBtn;


@end

@implementation StatusViewController

#define MARGIN 15.0f

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.challengesArray = [[NSMutableArray alloc] init];
    
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
	}

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    NSURL *userURL = [NSURL URLWithString:[[UserData sharedInstance] userDataPath]];
    NSURLRequest *userReq = [NSURLRequest requestWithURL:userURL];
    AFJSONRequestOperation *userOp = [AFJSONRequestOperation JSONRequestOperationWithRequest:userReq
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            JSON = [JSON objectForKey:@"Nitro"];
                                                                                            UserData *userData = [UserData sharedInstance];
                                                                                            [userData parseUserData:JSON];
                                                                                        }
                                                                                        failure:nil];

    NSString *baseURL = @"https://sandbox.bunchball.net/nitro/json?method=user.getChallengeProgress&showonlytrophies=false&showCanAchieveChallenge=true&sessionKey=";
    NSString *challengeString = [NSString stringWithFormat:@"%@%@", baseURL, [[UserData sharedInstance] sessionKey]];
    NSURL *challengeURL = [NSURL URLWithString:challengeString];
    NSURLRequest *challengeReq = [NSURLRequest requestWithURL:challengeURL];
    
    AFJSONRequestOperation *challengeOp = [AFJSONRequestOperation JSONRequestOperationWithRequest:challengeReq
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            JSON = [JSON objectForKey:@"Nitro"];
                                                                                            JSON = [JSON objectForKey:@"challenges"];
                                                                                            JSON = [JSON objectForKey:@"Challenge"];
                                                                                            [self finishedLoadingChallenges:JSON];
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            NSLog(@"%@", error);
                                                                                        }];

    NSArray *opArray = @[userOp, challengeOp];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@""]];
    [client enqueueBatchOfHTTPRequestOperations:opArray
                                  progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
                                      nil;
                                  }
                                completionBlock:^(NSArray *operations) {
                                    [self setupProfile];
                                }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIImage *leftImg = [UIImage imageNamed:@"menuBtn"];
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(10.0, 5.0, leftImg.size.width, leftImg.size.height);
    [leftButton setImage:leftImg forState:UIControlStateNormal];
    [leftButton addTarget:self.navigationController.parentViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    leftButton.tag = 1;
    [self.navigationController.navigationBar addSubview:leftButton];
    
    UIImage *rightImg = [UIImage imageNamed:@"refreshBtn"];
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(self.view.frame.size.width - rightImg.size.width - 10.0, 5.0, rightImg.size.width, rightImg.size.height);
    [rightBtn setImage:rightImg forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.tag = 2;
    [self.navigationController.navigationBar addSubview:rightBtn];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    UIButton *btn = (UIButton *)[self.navigationController.navigationBar viewWithTag:1];
    [btn removeFromSuperview];
    
    btn = (UIButton *)[self.navigationController.navigationBar viewWithTag:2];
    [btn removeFromSuperview];
}

- (void)refreshData {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSURL *userURL = [NSURL URLWithString:[[UserData sharedInstance] userDataPath]];
    NSURLRequest *userReq = [NSURLRequest requestWithURL:userURL];
    AFJSONRequestOperation *userOp = [AFJSONRequestOperation JSONRequestOperationWithRequest:userReq
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            JSON = [JSON objectForKey:@"Nitro"];
                                                                                            UserData *userData = [UserData sharedInstance];
                                                                                            [userData parseUserData:JSON];
                                                                                        }
                                                                                        failure:nil];

    NSString *baseURL = @"https://sandbox.bunchball.net/nitro/json?method=user.getChallengeProgress&showonlytrophies=false&showCanAchieveChallenge=true&sessionKey=";
    NSString *challengeString = [NSString stringWithFormat:@"%@%@", baseURL, [[UserData sharedInstance] sessionKey]];
    NSURL *challengeURL = [NSURL URLWithString:challengeString];
    NSURLRequest *challengeReq = [NSURLRequest requestWithURL:challengeURL];
    
    AFJSONRequestOperation *challengeOp = [AFJSONRequestOperation JSONRequestOperationWithRequest:challengeReq
                                                                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                              JSON = [JSON objectForKey:@"Nitro"];
                                                                                              JSON = [JSON objectForKey:@"challenges"];
                                                                                              JSON = [JSON objectForKey:@"Challenge"];
                                                                                              [self finishedLoadingChallenges:JSON];
                                                                                          }
                                                                                          failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                              NSLog(@"%@", error);
                                                                                          }];
    
    NSArray *opArray = @[userOp, challengeOp];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@""]];
    [client enqueueBatchOfHTTPRequestOperations:opArray
                                  progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
                                      nil;
                                  }
                                completionBlock:^(NSArray *operations) {
                                    [self updateProfile];
                                }];
}

- (void)updateProfile {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    UserData *userData = [UserData sharedInstance];

    _nameLabel.frame = CGRectMake(_nameLabel.frame.origin.x, _nameLabel.frame.origin.y, 0.0, 0.0);
    //NSString *nameLabelText = [NSString stringWithFormat:@"%@ %@", userData.formattedPoints, userData.pointsName];
    _nameLabel.text = @"15 Friends.";
    [_nameLabel sizeToFit];

    _friendsLabel.text = @"2 pending friend requests.";
    [_friendsLabel sizeToFit];
    
    for ( id obj in [_badgeScroller subviews] ) {
        [obj removeFromSuperview];
    }
    _badgeScroller.contentSize = CGSizeMake(0.0, 64.0);
    
    CGFloat xPos = 10.0;
    for ( int i = 0; i < [_challengesArray count]; ++i ) {
        
        NSString *imgName = [NSString stringWithFormat:@"badge_%@", ((ChallengeData *)[_challengesArray objectAtIndex:i]).badge];
        UIImage *badgeImg = [UIImage imageNamed:imgName];
        if ( ((ChallengeData *)[_challengesArray objectAtIndex:i]).completion < 1.0 ) badgeImg = [self getImageWithUnsaturatedPixelsOfImage:badgeImg];
        UIButton *badgeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        badgeBtn.frame = CGRectMake(xPos, 9.0, badgeImg.size.width, badgeImg.size.height);
        [badgeBtn setImage:badgeImg forState:UIControlStateNormal];
        
        [_badgeScroller addSubview:badgeBtn];
        
        if ( i == 4 || i == 9 ) xPos += 10.0;
        xPos += 10.0 + badgeImg.size.width;
        
        badgeBtn.tag = 1000 + i;
        [badgeBtn addTarget:self action:@selector(badgeTouched:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    CGFloat scrollWidth = ceilf([_challengesArray count]/5.0)*5.0*54.0 + 30.0;
    _badgeScroller.contentSize = CGSizeMake(scrollWidth, 64.0);
    
    UIView *oldHolder = [_feedScroller viewWithTag:100];
    
    UIView *feedHolder = [[UIView alloc] initWithFrame:CGRectZero];
    CGFloat yPos = 10.0;
    for ( NSDictionary *feedItem in userData.feedArray ) {
        NSString *imgPath = [NSString stringWithFormat:@"badge_%@", [feedItem objectForKey:@"iconPath"]];
        UIImageView *iconImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgPath]];
        iconImg.frame = CGRectMake( 10.0, yPos, 15.0, 15.0);
        [feedHolder addSubview:iconImg];
        
        
        NSString *content = [NSString stringWithFormat:@"      %@: %@", [feedItem objectForKey:@"handle"], [feedItem objectForKey:@"content"]];
        NSMutableAttributedString *attString=[[NSMutableAttributedString alloc] initWithString:content];
        
        NSRange handleRange = [content rangeOfString:[feedItem objectForKey:@"handle"]];
        UIFont *boldFont = [UIFont fontNamedLoRes9BoldOaklandWithSize:12.0];
        UIColor *boldColor = [UIColor blueColor];
        [attString addAttribute:NSFontAttributeName value:boldFont range:handleRange];
        [attString addAttribute:NSForegroundColorAttributeName value:boldColor range:handleRange];
        
        UILabel *feedLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, yPos + 1.0, oldHolder.frame.size.width - 20.0, 0.0)];
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
    
    //[self.view addSubview:_feedScroller];

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
                                                                   roundf(handleLabel.frame.origin.y + handleLabel.frame.size.height),
                                                                   400.0, 40.0)];
    _nameLabel.backgroundColor = [UIColor clearColor];
    _nameLabel.textColor = [UIColor blueColor];
    _nameLabel.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:14.0];
    _nameLabel.text = @"15 Friends.";
    [_nameLabel sizeToFit];
    [self.view addSubview:_nameLabel];
    
    self.friendsLabel = [[UILabel alloc] initWithFrame:CGRectMake(_nameLabel.frame.origin.x, _nameLabel.frame.origin.y + _nameLabel.frame.size.height + 1.0, 0.0, 0.0)];
    _friendsLabel.backgroundColor = [UIColor clearColor];
    _friendsLabel.textColor = [UIColor darkGrayColor];
    _friendsLabel.font = [UIFont fontNamedLoRes15BoldOaklandWithSize:14.0];
    _friendsLabel.text = @"2 pending friend requests.";
    [_friendsLabel sizeToFit];
    [self.view addSubview:_friendsLabel];
    
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
    
    self.collectionBack = [[BackgroundView alloc] initWithFrame:CGRectMake(MARGIN, yPos, totalWidth, 95.0)];
    [self.view addSubview:_collectionBack];
    
    self.collectionView = [[UIView alloc] initWithFrame:_collectionBack.frame];
    [self.view addSubview:_collectionView];
    
    /*
    UILabel *collectablesLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 0.0, 0.0)];
    collectablesLabel.backgroundColor = [UIColor clearColor];
    collectablesLabel.textColor = [UIColor blackColor];
    collectablesLabel.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:14.0];
    collectablesLabel.text = @"Collectables";
    [collectablesLabel sizeToFit];
    [_collectionView addSubview:collectablesLabel];
    
    UIView *blackLine = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                 collectablesLabel.frame.origin.y + collectablesLabel.frame.size.height + 5.0,
                                                                 _collectionBack.frame.size.width, 2.0)];
    blackLine.backgroundColor = [UIColor blackColor];
    [_collectionView addSubview:blackLine];
    */
    
    self.badgeScroller = [[UIScrollView alloc] initWithFrame:CGRectMake(3.0, 3.0, _collectionBack.frame.size.width - 11.0, 64.0)];
    _badgeScroller.pagingEnabled = YES;
    _badgeScroller.showsHorizontalScrollIndicator = NO;
    [_collectionView addSubview:_badgeScroller];
    
    CGFloat xPos = 10.0;
    
    for ( int i = 0; i < [_challengesArray count]; ++i ) {
        
        NSString *imgName = [NSString stringWithFormat:@"badge_%@", ((ChallengeData *)[_challengesArray objectAtIndex:i]).badge];
        UIImage *badgeImg = [UIImage imageNamed:imgName];
        if ( ((ChallengeData *)[_challengesArray objectAtIndex:i]).completion < 1.0 ) badgeImg = [self getImageWithUnsaturatedPixelsOfImage:badgeImg];
        UIButton *badgeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        badgeBtn.frame = CGRectMake(xPos, 9.0, badgeImg.size.width, badgeImg.size.height);
        [badgeBtn setImage:badgeImg forState:UIControlStateNormal];
        
        [_badgeScroller addSubview:badgeBtn];
        
        if ( i == 4 || i == 9 ) xPos += 10.0;
        xPos += 10.0 + badgeImg.size.width;
        
        badgeBtn.tag = 1000 + i;
        [badgeBtn addTarget:self action:@selector(badgeTouched:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    CGFloat scrollWidth = ceilf([_challengesArray count]/5.0)*5.0*54.0 + 30.0;
    _badgeScroller.contentSize = CGSizeMake(scrollWidth, 64.0);
    
    UIView *blackLine = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                 _badgeScroller.frame.origin.y + _badgeScroller.frame.size.height,
                                                                 _collectionBack.frame.size.width, 2.0)];
    blackLine.backgroundColor = [UIColor blackColor];
    [_collectionView addSubview:blackLine];
    
    self.tapLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, blackLine.frame.origin.y + 2.0, blackLine.frame.size.width - 25.0, 39.0)];
    _tapLabel.backgroundColor = [UIColor clearColor];
    _tapLabel.textColor = [UIColor grayColor];
    _tapLabel.font = [UIFont fontNamedLoRes15BoldOaklandWithSize:15.0];
    _tapLabel.text = @"Tap a collectable to learn more...";
    [_collectionView addSubview:_tapLabel];
    
    self.challengeInfoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _challengeInfoBtn.backgroundColor = [UIColor clearColor];
    _challengeInfoBtn.frame = CGRectMake(0.0, _tapLabel.frame.origin.y, _collectionBack.frame.size.width, 44.0);
    [_challengeInfoBtn addTarget:self action:@selector(challengeBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    [_collectionView addSubview:_challengeInfoBtn];
    _challengeInfoBtn.alpha = 0.0;
    
    UILabel *challengeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 11.0, 0.0, 0.0)];
    challengeLabel.backgroundColor = [UIColor clearColor];
    challengeLabel.textColor = [UIColor blueColor];
    challengeLabel.font = [UIFont fontNamedLoRes15BoldOaklandWithSize:15.0];
    challengeLabel.text = @"";
    [challengeLabel sizeToFit];
    challengeLabel.tag = 2000;
    [_challengeInfoBtn addSubview:challengeLabel];

    UIImageView *arrowImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_right"]];
    arrowImg.frame = CGRectMake(_challengeInfoBtn.frame.size.width - 28.0, 15.0, 10.0, 10.0);
    [_challengeInfoBtn addSubview:arrowImg];

    frame = _collectionBack.frame;
    frame.size.height = _badgeScroller.frame.size.height + _badgeScroller.frame.origin.y + 5.0 + 44.0;
    _collectionBack.frame = frame;
    [_collectionBack setNeedsDisplay];
    
    yPos = _collectionBack.frame.origin.y + _collectionBack.frame.size.height + 10.0;
    
    backView = [[BackgroundView alloc] initWithFrame:CGRectMake(MARGIN, yPos, totalWidth, self.view.frame.size.height - yPos - 10.0)];
    [self.view addSubview:backView];
    
    UILabel *stalkingLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 1.0, 1.0)];
    stalkingLabel.backgroundColor = [UIColor clearColor];
    stalkingLabel.textColor = [UIColor blackColor];
    stalkingLabel.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:14.0];
    stalkingLabel.text = @"Activity feed";
    [stalkingLabel sizeToFit];
    [backView addSubview:stalkingLabel];
    

    blackLine = [[UIView alloc] initWithFrame:CGRectMake(0.0, stalkingLabel.frame.origin.y + stalkingLabel.frame.size.height + 5.0, backView.frame.size.width, 2.0)];
    blackLine.backgroundColor = [UIColor blackColor];
    [backView addSubview:blackLine];
    
    self.feedScroller = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, blackLine.frame.origin.y + 2.0, blackLine.frame.size.width - 5.0, backView.frame.size.height - blackLine.frame.origin.y - 9.0)];

    UIView *feedHolder = [[UIView alloc] initWithFrame:CGRectZero];
    yPos = 10.0;
    for ( NSDictionary *feedItem in userData.feedArray ) {
        NSString *imgPath = [NSString stringWithFormat:@"badge_%@", [feedItem objectForKey:@"iconPath"]];
        UIImageView *iconImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgPath]];
        iconImg.frame = CGRectMake( 10.0, yPos, 15.0, 15.0);
        [feedHolder addSubview:iconImg];
        
        
        NSString *content = [NSString stringWithFormat:@"      %@: %@", [feedItem objectForKey:@"handle"], [feedItem objectForKey:@"content"]];
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:content];
        
        NSRange handleRange = [content rangeOfString:[feedItem objectForKey:@"handle"]];
        UIFont *boldFont = [UIFont fontNamedLoRes9BoldOaklandWithSize:12.0];
        UIColor *boldColor = [UIColor blueColor];
        [attString addAttribute:NSFontAttributeName value:boldFont range:handleRange];
        [attString addAttribute:NSForegroundColorAttributeName value:boldColor range:handleRange];
        
        UILabel *feedLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, yPos + 1.0, backView.frame.size.width - 25.0, 0.0)];
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
    
    [backView addSubview:_feedScroller];
}

- (void)finishedLoadingChallenges:(NSDictionary *)JSON {
    [self.challengesArray removeAllObjects];
    
    for ( NSDictionary *dict in JSON ) {
        ChallengeData *challenge = [[ChallengeData alloc] initWithDictionary:dict];
        if ( [challenge.title rangeOfString:@"facebook"].location == NSNotFound ) [_challengesArray addObject:challenge];
    }
}

- (void)badgeTouched:(id)sender {
    UIButton *btn = (UIButton *)sender;
    ChallengeData *challenge = [_challengesArray objectAtIndex:[sender tag] - 1000];
    
    for ( id obj in [_badgeScroller subviews] ) {
        UIButton *inactiveBtn = (UIButton *)obj;
        if ( inactiveBtn != btn ) {
            inactiveBtn.userInteractionEnabled = YES;

            [UIView animateWithDuration:.15
                                  delay:0.0
                                options:UIViewAnimationCurveEaseOut
                             animations:^{
                                 inactiveBtn.transform = CGAffineTransformMakeScale(1.0, 1.0);
                             }
                             completion:^(BOOL finished) {
                             }];
        }
    }

    btn.userInteractionEnabled = NO;

    [UIView animateWithDuration:.15
                          delay:0.0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                         btn.transform = CGAffineTransformMakeScale(1.2, 1.2);
                     }
                     completion:^(BOOL finished) {
                     }];
    
    if ( _tapLabel.alpha == 1.0 ) {
        _challengeInfoBtn.tag = [sender tag];
        [self updateChallengeInfoBtn:challenge];
        [UIView animateWithDuration:.15
                              delay:0.0
                            options:UIViewAnimationCurveEaseOut
                         animations:^{
                             _tapLabel.alpha = 0.0;
                             _challengeInfoBtn.alpha = 1.0;
                         }
                         completion:^(BOOL finished) {
                         }];
    }
    else {
        _challengeInfoBtn.tag = [sender tag];
        [self updateChallengeInfoBtn:challenge];
    }

}

- (void)updateChallengeInfoBtn:(ChallengeData *)data {
    UILabel *lbl = (UILabel *)[self.view viewWithTag:2000];
    lbl.frame = CGRectMake(10.0, 0.0, _challengeInfoBtn.frame.size.width - 38.0, 100.0);
    lbl.numberOfLines = 0;
    lbl.lineBreakMode = NSLineBreakByWordWrapping;
    lbl.text = [data.title uppercaseString];
    
    [lbl sizeToFit];
    CGRect frame = lbl.frame;
    frame.origin.y = 22.0 - lbl.frame.size.height*.5 - 2.0;
    lbl.frame = frame;
}

- (void)challengeBtnTouched:(id)sender {
    ChallengeData *challenge = [_challengesArray objectAtIndex:[sender tag] - 1000];
    ChallengeDetailViewController *challengeVC = [[ChallengeDetailViewController alloc] initWithData:challenge];
    [self.navigationController pushViewController:challengeVC animated:YES];
}

- (UIImage *)getImageWithUnsaturatedPixelsOfImage:(UIImage *)image {
    const int RED = 1, GREEN = 2, BLUE = 3;
    
    CGRect imageRect = CGRectMake(0, 0, image.size.width*2, image.size.height*2);
    
    int width = imageRect.size.width, height = imageRect.size.height;
    
    uint32_t * pixels = (uint32_t *) malloc(width*height*sizeof(uint32_t));
    memset(pixels, 0, width * height * sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [image CGImage]);
    
    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t * rgbaPixel = (uint8_t *) &pixels[y*width+x];
            uint32_t gray = (0.3*rgbaPixel[RED]+0.59*rgbaPixel[GREEN]+0.11*rgbaPixel[BLUE]);
            
            rgbaPixel[RED] = gray;
            rgbaPixel[GREEN] = gray;
            rgbaPixel[BLUE] = gray;
        }
    }
    
    CGImageRef newImage = CGBitmapContextCreateImage(context);
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    
    UIImage * resultUIImage = [UIImage imageWithCGImage:newImage scale:2 orientation:0];
    CGImageRelease(newImage);
    
    return resultUIImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
//
//  ProfileViewController.m
//  LoyaltyPrototype
//
//  Created by Jason Grandelli on 1/17/13.
//  Copyright (c) 2013 URBN. All rights reserved.
//

#import "ProfileViewController.h"
#import "BackgroundView.h"
#import "UIFont+UrbanAdditions.h"
#import "NavBarItemsViewController.h"
#import "UserData.h"
#import <AFNetworking.h>
#import <MBProgressHUD.h>
#import "ChallengeData.h"
#import <QuartzCore/QuartzCore.h>
#import "ProfileGraduateViewController.h"
#import "ProfileShareViewController.h"

@interface ProfileViewController ()

@property (nonatomic, strong) NavBarItemsViewController *navBarItems;
@property (nonatomic, strong) NSMutableArray *challengesArray;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UILabel *percLabel;
@property (nonatomic, strong) UIView *percBar;
@property (nonatomic, strong) UIView *percBarBack;
@property (nonatomic) BOOL built;

@end

@implementation ProfileViewController

#define MARGIN 15.0f
#define PADDING 10.0f
#define PROGRESS_PATH @"https://sandbox.bunchball.net/nitro/json?method=user.getChallengeProgress&showonlytrophies=false&showCanAchieveChallenge=true&folder=MYUO%20Profile%20Challenges"

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.challengesArray = [[NSMutableArray alloc] init];
    
    int i = (arc4random() % 9) + 1;
    NSString *patternName = [NSString stringWithFormat:@"Background%i", i];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:patternName]];
    
    self.navBarItems = [[NavBarItemsViewController alloc] init];
    _navBarItems.pageName = @"MYUO Profile";
    [_navBarItems.view setFrame:self.navigationController.navigationBar.bounds];
    [self.navigationController.navigationBar addSubview:_navBarItems.view];
    
    if ([self.navigationController.parentViewController respondsToSelector:@selector(revealGesture:)] &&
        [self.navigationController.parentViewController respondsToSelector:@selector(revealToggle:)])
    {
        UIPanGestureRecognizer *navigationBarPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self.navigationController.parentViewController action:@selector(revealGesture:)];
		[self.navigationController.navigationBar addGestureRecognizer:navigationBarPanGestureRecognizer];
	}
    
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *userPath = [[UserData sharedInstance] userDataPath];
    NSURL *userURL = [NSURL URLWithString:userPath];
    NSURLRequest *userReq = [NSURLRequest requestWithURL:userURL];
    AFJSONRequestOperation *userOp = [AFJSONRequestOperation JSONRequestOperationWithRequest:userReq
                                                                                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                         JSON = [JSON objectForKey:@"Nitro"];
                                                                                         UserData *userData = [UserData sharedInstance];
                                                                                         [userData parseUserData:JSON];
                                                                                         [_navBarItems updateInfo];
                                                                                     }
                                                                                     failure:nil];

    NSString *progressPath = [NSString stringWithFormat:@"%@&sessionKey=%@", PROGRESS_PATH, [[UserData sharedInstance] sessionKey]];
    NSURL *progressURL = [NSURL URLWithString:progressPath];
    NSURLRequest *progressReq = [NSURLRequest requestWithURL:progressURL];
    AFJSONRequestOperation *progressOp = [AFJSONRequestOperation JSONRequestOperationWithRequest:progressReq
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            JSON = [[JSON objectForKey:@"Nitro"] objectForKey:@"challenges"];
                                                                                            [self finishedLoadingProgress:JSON];
                                                                                        }
                                                                                        failure:nil];


    NSArray *opArray = @[userOp, progressOp];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@""]];
    [client enqueueBatchOfHTTPRequestOperations:opArray
                                  progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
                                      nil;
                                  }
                                completionBlock:^(NSArray *operations) {
                                    //[self finishedBatchOperationBatch];
                                    [self buildLayout];
                                }];
}

- (void)refreshData {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *userPath = [[UserData sharedInstance] userDataPath];
    NSURL *userURL = [NSURL URLWithString:userPath];
    NSURLRequest *userReq = [NSURLRequest requestWithURL:userURL];
    AFJSONRequestOperation *userOp = [AFJSONRequestOperation JSONRequestOperationWithRequest:userReq
                                                                                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                         JSON = [JSON objectForKey:@"Nitro"];
                                                                                         UserData *userData = [UserData sharedInstance];
                                                                                         [userData parseUserData:JSON];
                                                                                         [_navBarItems updateInfo];
                                                                                     }
                                                                                     failure:nil];
    [userOp start];
    
    NSString *progressPath = [NSString stringWithFormat:@"%@&sessionKey=%@", PROGRESS_PATH, [[UserData sharedInstance] sessionKey]];
    NSURL *progressURL = [NSURL URLWithString:progressPath];
    NSURLRequest *progressReq = [NSURLRequest requestWithURL:progressURL];
    AFJSONRequestOperation *progressOp = [AFJSONRequestOperation JSONRequestOperationWithRequest:progressReq
                                                                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                             JSON = [[JSON objectForKey:@"Nitro"] objectForKey:@"challenges"];
                                                                                             [self finishedLoadingProgress:JSON];
                                                                                             
                                                                                             [self updateDataInView];
                                                                                         }
                                                                                         failure:nil];
    
    [progressOp start];
}

- (void)finishedLoadingProgress:(NSDictionary *)JSON {
    [_challengesArray removeAllObjects];
    
    for ( NSDictionary *dict in [JSON objectForKey:@"Challenge"] ) {
        ChallengeData *challenge = [[ChallengeData alloc] initWithDictionary:dict];
        [_challengesArray addObject:challenge];
    }
}

- (void)buildLayout {
    self.built = YES;
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    UserData *userData = [UserData sharedInstance];
    
    CGFloat totalWidth = self.view.frame.size.width - MARGIN*2;
    
    BackgroundView *backView = [[BackgroundView alloc] initWithFrame:CGRectMake(MARGIN, roundf(navBar.frame.size.height + MARGIN), totalWidth, 95.0)];
    [self.view addSubview:backView];

    UIImageView *profileImgView = [[UIImageView alloc] initWithFrame:CGRectMake(roundf(backView.frame.origin.x + PADDING), roundf(backView.frame.origin.y + PADDING), 70.0, 70.0)];
    [profileImgView setImageWithURL:[NSURL URLWithString:userData.imgPath]];
    profileImgView.layer.borderWidth = 2;
    profileImgView.layer.borderColor = [UIColor blackColor].CGColor;
    [self.view addSubview:profileImgView];
    
    CGFloat compPerc = 0.0;
    int completedSections = 0;
    for ( ChallengeData *data in _challengesArray ) {
        if ( data.completion == 1.0 ) completedSections++;
        compPerc += data.completion;
    }
    compPerc /= [_challengesArray count];
    
    NSString *titleString = [NSString stringWithFormat:@"Sections Completed: %i of %i", completedSections, [_challengesArray count]];
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:titleString];
    NSRange compRange = [titleString rangeOfString:[NSString stringWithFormat:@"%i", completedSections]];
    NSRange countRange = [titleString rangeOfString:[NSString stringWithFormat:@"%i", [_challengesArray count]] options:4];
    UIFont *boldFont = [UIFont fontNamedLoRes9BoldOaklandWithSize:18.0];
    UIColor *boldColor = [UIColor blueColor];
    [attString addAttribute:NSFontAttributeName value:boldFont range:compRange];
    [attString addAttribute:NSForegroundColorAttributeName value:boldColor range:compRange];
    [attString addAttribute:NSFontAttributeName value:boldFont range:countRange];
    [attString addAttribute:NSForegroundColorAttributeName value:boldColor range:countRange];
    
    self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(profileImgView.frame.origin.x + 70.0 + PADDING,
                                                                    profileImgView.frame.origin.y,
                                                                    backView.frame.size.width - (profileImgView.frame.origin.x + 70.0 + PADDING - 5.0),
                                                                    0.0)];
    _countLabel.backgroundColor = [UIColor clearColor];
    _countLabel.textColor = [UIColor blackColor];
    _countLabel.numberOfLines = 0;
    _countLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _countLabel.font = [UIFont fontNamedLoRes15BoldOaklandWithSize:15.0];
    _countLabel.attributedText = attString;
    [_countLabel sizeToFit];
    [self.view addSubview:_countLabel];
    
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(_countLabel.frame.origin.x,
                                                                   roundf(_countLabel.frame.origin.y + _countLabel.frame.size.height + 7.0),
                                                                   backView.frame.size.width - (profileImgView.frame.origin.x + 70.0 + PADDING),
                                                                   0.0)];
    infoLabel.backgroundColor = [UIColor clearColor];
    infoLabel.textColor = [UIColor blackColor];
    infoLabel.numberOfLines = 0;
    infoLabel.lineBreakMode = NSLineBreakByWordWrapping;
    infoLabel.font = [UIFont fontNamedLoRes22BoldOaklandWithSize:17.0];
    infoLabel.text = @"Complete each section to earn exclusive perks and privileges.";
    [infoLabel sizeToFit];
    [self.view addSubview:infoLabel];
    
    
    UILabel *totalCompLabel = [[UILabel alloc] initWithFrame:CGRectMake(profileImgView.frame.origin.x, profileImgView.frame.origin.y + profileImgView.frame.size.height + PADDING, 0.0, 0.0)];
    totalCompLabel.backgroundColor = [UIColor clearColor];
    totalCompLabel.textColor = [UIColor blackColor];
    totalCompLabel.font = [UIFont fontNamedLoRes15BoldOaklandWithSize:15.0];
    totalCompLabel.text = @"Your profile is:";
    [totalCompLabel sizeToFit];
    [self.view addSubview:totalCompLabel];
    
    totalWidth = backView.frame.size.width - PADDING*2 - 5.0;
    
    self.percLabel = [[UILabel alloc] initWithFrame:CGRectMake(totalCompLabel.frame.origin.x + 5.0,
                                                                         totalCompLabel.frame.origin.y + totalCompLabel.frame.size.height + 8.0,
                                                                         totalWidth,
                                                                         10.0)];
    _percLabel.backgroundColor = [UIColor clearColor];
    _percLabel.textColor = [UIColor whiteColor];
    _percLabel.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:13.0];
    int perc = compPerc * 100;
    _percLabel.text = [NSString stringWithFormat:@"%i%% completed", perc];
    [_percLabel sizeToFit];
    [self.view addSubview:_percLabel];
    
    self.percBar = [[UIView alloc] initWithFrame:CGRectMake(_percLabel.frame.origin.x - 5.0,
                                                                         _percLabel.frame.origin.y - 5.0,
                                                                         totalWidth * compPerc,
                                                                         _percLabel.frame.size.height + 10.0)];
    _percBar.backgroundColor = [UIColor redColor];
    [self.view insertSubview:_percBar belowSubview:_percLabel];
    
    self.percBarBack = [[UIView alloc] initWithFrame:CGRectMake(_percBar.frame.origin.x,
                                                                         _percLabel.frame.origin.y - 5.0,
                                                                         totalWidth,
                                                                         _percLabel.frame.size.height + 10.0)];
    _percBarBack.backgroundColor = [UIColor darkGrayColor];
    [self.view insertSubview:_percBarBack belowSubview:_percBar];
    
    CGRect frame = backView.frame;
    frame.size.height = (_percBarBack.frame.origin.y - backView.frame.origin.y) + _percBarBack.frame.size.height + PADDING + 5.0;
    backView.frame = frame;
    [backView setNeedsDisplay];
    
    CGFloat yPos = backView.frame.origin.y + backView.frame.size.height + 30.0;
    int ind = 100;
    for ( ChallengeData *section in _challengesArray ) {
        UIButton *sectionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        sectionBtn.frame = CGRectMake(MARGIN, yPos, self.view.frame.size.width - MARGIN*2, 44.0);

        BackgroundView *btnBack = [[BackgroundView alloc] initWithFrame:CGRectMake(0.0, 0.0, sectionBtn.frame.size.width, sectionBtn.frame.size.height)];
        btnBack.userInteractionEnabled = NO;
        [sectionBtn addSubview:btnBack];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, PADDING, 0.0, 0.0)];
        title.backgroundColor = [UIColor clearColor];
        title.textColor = [UIColor blackColor];
        title.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:16.0];
        title.text = section.title;
        [title sizeToFit];
        title.tag = 10;
        [sectionBtn addSubview:title];

        perc = section.completion * 100;
        UILabel *ruleCount = [[UILabel alloc] initWithFrame:CGRectMake(title.frame.origin.x + title.frame.size.width + 4.0, title.frame.origin.y, 0.0, 0.0)];
        ruleCount.backgroundColor = [UIColor clearColor];
        if ( perc < 100 ) ruleCount.textColor = [UIColor redColor];
        else ruleCount.textColor = [UIColor colorWithRed:0.004 green:0.682 blue:0.004 alpha:1.000];
        ruleCount.font = title.font;
        ruleCount.text = [NSString stringWithFormat:@"(%i%%)", perc];
        [ruleCount sizeToFit];
        ruleCount.tag = 11;
        [sectionBtn addSubview:ruleCount];
        
        [self.view addSubview:sectionBtn];
        
        UIImageView *arrowImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_right"]];
        arrowImg.frame = CGRectMake(sectionBtn.frame.size.width - 28.0, 14.0, 10.0, 10.0);
        [sectionBtn addSubview:arrowImg];
        
        sectionBtn.tag = ind;
        [sectionBtn addTarget:self action:@selector(sectionBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        
        ind++;
        yPos += sectionBtn.frame.size.height + 10.0;
    }
}

- (void)updateDataInView {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    CGFloat compPerc = 0.0;
    int completedSections = 0;
    for ( ChallengeData *data in _challengesArray ) {
        if ( data.completion == 1.0 ) completedSections++;
        compPerc += data.completion;
    }
    compPerc /= [_challengesArray count];
    
    NSString *titleString = [NSString stringWithFormat:@"Sections Completed: %i of %i", completedSections, [_challengesArray count]];
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:titleString];
    NSRange compRange = [titleString rangeOfString:[NSString stringWithFormat:@"%i", completedSections]];
    NSRange countRange = [titleString rangeOfString:[NSString stringWithFormat:@"%i", [_challengesArray count]] options:4];
    UIFont *boldFont = [UIFont fontNamedLoRes9BoldOaklandWithSize:18.0];
    UIColor *boldColor = [UIColor blueColor];
    [attString addAttribute:NSFontAttributeName value:boldFont range:compRange];
    [attString addAttribute:NSForegroundColorAttributeName value:boldColor range:compRange];
    [attString addAttribute:NSFontAttributeName value:boldFont range:countRange];
    [attString addAttribute:NSForegroundColorAttributeName value:boldColor range:countRange];
    
    _countLabel.attributedText = attString;
    [_countLabel sizeToFit];


    int perc = compPerc * 100;
    _percLabel.text = [NSString stringWithFormat:@"%i%% completed", perc];
    [_percLabel sizeToFit];
    
    [_percBar setFrame:CGRectMake(_percBarBack.frame.origin.x, _percBarBack.frame.origin.y, _percBarBack.frame.size.width * compPerc, _percBarBack.frame.size.height)];
    
    for ( int i = 0; i < [_challengesArray count]; ++i ) {
        UIButton *btn = (UIButton *)[self.view viewWithTag:i + 100];
        UILabel *percLabel = (UILabel *)[btn viewWithTag:11];
        
        ChallengeData *challenge = [_challengesArray objectAtIndex:i];
        
        perc = challenge.completion * 100;
        
        CGRect frame = percLabel.frame;
        frame.size.width = 0.0;
        frame.size.height = 0.0;
        percLabel.frame = frame;
        if ( perc < 100 ) percLabel.textColor = [UIColor redColor];
        else percLabel.textColor = [UIColor colorWithRed:0.004 green:0.682 blue:0.004 alpha:1.000];
        percLabel.text = [NSString stringWithFormat:@"(%i%%)", perc];
        [percLabel sizeToFit];
    }
}

- (void)sectionBtnTouched:(id)sender {
    ChallengeData *data = [_challengesArray objectAtIndex:[sender tag] - 100];
    switch ( [sender tag] ) {
        case 100:
            NSLog(@"");
            break;
        case 101:
            NSLog(@"");
            break;
        case 102: {
                ProfileGraduateViewController *gradController = [[ProfileGraduateViewController alloc] initWithData:data];
                [self.navigationController pushViewController:gradController animated:YES];
            }
            break;
        case 103: {
                ProfileShareViewController *shareController = [[ProfileShareViewController alloc] initWithData:data];
                [self.navigationController pushViewController:shareController animated:YES];
            }
            break;
    }
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
    
    if ( _built ) [self refreshData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    UIButton *btn = (UIButton *)[self.navigationController.navigationBar viewWithTag:1];
    [btn removeFromSuperview];
    
    btn = (UIButton *)[self.navigationController.navigationBar viewWithTag:2];
    [btn removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

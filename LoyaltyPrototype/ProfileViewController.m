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

@property NavBarItemsViewController *navBarItems;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    //[self.view addSubview:backgroundImage];
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
    
    self.navBarItems = [[NavBarItemsViewController alloc] init];
    [_navBarItems.view setFrame:self.navigationController.navigationBar.bounds];
    [self.navigationController.navigationBar addSubview:_navBarItems.view];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *userPath = @"http://beta.bunchball.net/nitro/json?method=batch.run&methodFeed=%5B%22method=user.login%26apiKey=a06f6dbdb43f4c2293fa615576e4c7dc%26userID=123%22,%22method=user.getPreferences%26userId=123%22,%22method=user.getPointsBalance%26pointCategory=all%26includeYearlyCredits=false%26criteria=BALANCE%22,%22method=user.getLevel%22,%22method=user.getNextLevel%22,%22method=site.getActionFeed%26apiKey=a06f6dbdb43f4c2293fa615576e4c7dc%22%5D";
    NSURL *userURL = [NSURL URLWithString:userPath];
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

- (void)updateNavBarItems {
    [_navBarItems updateInfo];
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
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(handleLabel.frame.origin.x,
                                                                   handleLabel.frame.origin.y + handleLabel.frame.size.height + 2.0,
                                                                   400.0, 40.0)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.numberOfLines = 2;
    nameLabel.textColor = [UIColor neonBlue];
    nameLabel.font = [UIFont systemFontOfSize:13.0];
    NSString *nameLabelText = nil;
    if ( userData.firstName ) nameLabelText = [NSString stringWithFormat:@"AKA: %@ %@\n%@", userData.firstName, userData.lastName, userData.currentLevel];
    else nameLabelText = userData.currentLevel;
    nameLabel.text = nameLabelText;
    [nameLabel sizeToFit];
    [self.view addSubview:nameLabel];
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x,
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
    
    UILabel *nextLevelLabel = [[UILabel alloc] initWithFrame:CGRectMake(profileImgView.frame.origin.x,
                                                                        profileImgView.frame.origin.y + profileImgView.frame.size.height + 25.0,
                                                                        self.view.bounds.size.width - 30.0, 40.0)];
    nextLevelLabel.backgroundColor = [UIColor clearColor];
    nextLevelLabel.font = [UIFont systemFontOfSize:13.0];
    nextLevelLabel.textColor = [UIColor offWhite];
    nextLevelLabel.text = [NSString stringWithFormat:@"Next Level: %@ %@ points", userData.nextLevel, userData.formattedNextLevelGoal];
    [nextLevelLabel sizeToFit];
    [self.view addSubview:nextLevelLabel];
    
    UIView *progressBack = [[UIView alloc] initWithFrame:CGRectMake(profileImgView.frame.origin.x,
                                                                    nextLevelLabel.frame.origin.y + nextLevelLabel.frame.size.height + 2.0,
                                                                    self.view.bounds.size.width - 30.0, 7.0)];
    progressBack.backgroundColor = [UIColor offWhite];
    [self.view addSubview:progressBack];
    
    CGFloat progressWidth = progressBack.frame.size.width * userData.percentAchieved;
    
    UIView *progressBar = [[UIView alloc] initWithFrame:CGRectMake(progressBack.frame.origin.x,
                                                                   progressBack.frame.origin.y,
                                                                   progressWidth, progressBack.frame.size.height)];
    progressBar.backgroundColor = [UIColor neonGreen];
    [self.view addSubview:progressBar];
    
    UILabel *progressPercentLabel = [[UILabel alloc] initWithFrame:CGRectMake(nextLevelLabel.frame.origin.x,
                                                                              progressBack.frame.origin.y + progressBack.frame.size.height + 2.0,
                                                                          100.0, 40.0)];
    progressPercentLabel.backgroundColor = [UIColor clearColor];
    progressPercentLabel.textColor = [UIColor offWhite];
    progressPercentLabel.font = [UIFont systemFontOfSize:12.0];
    int percValue = userData.percentAchieved * 100;
    progressPercentLabel.text = [NSString stringWithFormat:@"%i%%", percValue];
    [progressPercentLabel sizeToFit];
    [self.view addSubview:progressPercentLabel];
    
    UILabel *pointsToGoLabel = [[UILabel alloc] initWithFrame:CGRectMake(nextLevelLabel.frame.origin.x,
                                                                         progressPercentLabel.frame.origin.y,
                                                                         self.view.bounds.size.width - 30.0, progressPercentLabel.frame.size.height)];
    pointsToGoLabel.backgroundColor = [UIColor clearColor];
    pointsToGoLabel.textAlignment = NSTextAlignmentRight;
    pointsToGoLabel.textColor = [UIColor offWhite];
    pointsToGoLabel.font = progressPercentLabel.font;
    pointsToGoLabel.text = [NSString stringWithFormat:@"%@ more to go", userData.formattedPointsToGo];
    [self.view addSubview:pointsToGoLabel];
    
    UIView *greenLine = [[UIView alloc] initWithFrame:CGRectMake(profileImgView.frame.origin.x,
                                                                 pointsToGoLabel.frame.origin.y + pointsToGoLabel.frame.size.height + 30.0,
                                                                 progressBack.frame.size.width, 1.0)];
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
                                                                 pointsToGoLabel.frame.origin.y + pointsToGoLabel.frame.size.height + 65.0,
                                                                 progressBack.frame.size.width, 1.0)];
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
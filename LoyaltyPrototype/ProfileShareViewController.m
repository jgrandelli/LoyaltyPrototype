//
//  ProfileShareViewController.m
//  LoyaltyPrototype
//
//  Created by Jason Grandelli on 1/21/13.
//  Copyright (c) 2013 URBN. All rights reserved.
//

#import "ProfileShareViewController.h"
#import "BackgroundView.h"
#import "UIFont+UrbanAdditions.h"
#import "NavBarItemsViewController.h"
#import <AFNetworking.h>
#import <MBProgressHUD.h>
#import <QuartzCore/QuartzCore.h>
#import <TTSwitch.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "UserData.h"

@interface ProfileShareViewController ()

@property (nonatomic, strong) ChallengeData *data;
@property (nonatomic, strong) UIView *compBar;
@property (nonatomic, strong) UIView *compBarBack;
@property (nonatomic, strong) UILabel *compBarLabel;


@end

@implementation ProfileShareViewController

#define MARGIN 15.0f
#define PADDING 10.0f
#define BASE_URL @"https://sandbox.bunchball.net/nitro/json?value=0&method=user%2ElogAction&metadata=&competitionInstanceId=&newsfeed=&target=&tags=sharewithus_twitter&userId=16&asyncToken=&storeResponse=false"

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
    
    
    
    CGFloat yPos = backView.frame.origin.y + backView.frame.size.height + 20.0;
    NSArray *socialArray = @[@"Twitter", @"Facebook", @"Instagram"];
    for ( int i = 0; i < 3; ++i ) {
        backView = [[BackgroundView alloc] initWithFrame:CGRectMake(MARGIN, yPos, totalWidth, 100.0)];
        [self.view addSubview:backView];
        
        NSString *iconName = [[socialArray objectAtIndex:i] lowercaseString];
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING, PADDING, 28.0, 28.0)];
        [icon setImage:[UIImage imageNamed:iconName]];
        [backView addSubview:icon];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(icon.frame.size.width + icon.frame.origin.x + 10.0, PADDING + 2.0, 0.0, 0.0)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:20.0];
        titleLabel.text = [socialArray objectAtIndex:i];
        [titleLabel sizeToFit];
        [backView addSubview:titleLabel];
        
        TTSwitch *defaultSwitch = [[TTSwitch alloc] initWithFrame:CGRectMake(backView.frame.size.width - 76.0 - 8.0 - PADDING, PADDING, 76.0, 27.0)];
        defaultSwitch.tag = 10 + i;
        if ( i == 0 ) [defaultSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        //defaultSwitch
        [backView addSubview:defaultSwitch];
        
        CGRect frame = backView.frame;
        frame.size.height = icon.frame.size.height + icon.frame.origin.y + PADDING + 5.0;
        backView.frame = frame;
        [backView setNeedsDisplay];
        
        yPos += backView.frame.size.height + 10.0;
    }
}

- (void)switchChanged:(id)sender {
    TTSwitch *defaultSwitch = (TTSwitch *)sender;
    if ( [defaultSwitch isOn] ) {

        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            ACAccountStore *account = [[ACAccountStore alloc] init];
            ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
            
            [account requestAccessToAccountsWithType:accountType options:nil
                                          completion:^(BOOL granted, NSError *error) {
                                              if (granted == YES) {
                                                  // Get account and communicate with Twitter API
                                                  //NSLog(@"%d --- %@", granted, accountType);
                                                  //NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
                                                  //NSLog(@"array of accounts = %@", arrayOfAccounts);
                                                  
                                                  //[self sendCompletion];
                                              }
            }];
        }
    }

    [self sendCompletion];
}

- (void)sendCompletion {
    NSString *urlString = [NSString stringWithFormat:@"%@&sessionKey=%@", BASE_URL, [[UserData sharedInstance] sessionKey]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:req
                                                                                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                     [self completionSubmitted];
                                                                                     NSLog(@"json = %@", JSON);
                                                                                 }
                                                                                 failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                     NSLog(@"FAILURES~!!!!!");
                                                                                     NSLog(@"response = %@\n\n", response);
                                                                                     NSLog(@"error = %@", error);
                                                                                 }];
    
    [op start];
}

- (void)completionSubmitted {
//    [self.navigationController popViewControllerAnimated:YES];
}



- (void)backBtnPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

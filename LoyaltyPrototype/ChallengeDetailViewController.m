//
//  ChallengeDetailViewController.m
//  LoyaltyPrototype
//
//  Created by Jason Grandelli on 1/2/13.
//  Copyright (c) 2013 URBN. All rights reserved.
//

#import "ChallengeDetailViewController.h"
#import "UIColor+ColorConstants.h"
#import "UIFont+UrbanAdditions.h"
#import "BackgroundView.h"
#import <Social/Social.h>
#import "ViewController.h"
#import "MenuViewController.h"
#import "ProfileViewController.h"

@interface ChallengeDetailViewController ()

@property (nonatomic, strong) ChallengeData *challengeData;

@end

@implementation ChallengeDetailViewController

#define MARGIN 15.0f
#define INNER_PADDING 10.0f

- (id)initWithData:(ChallengeData *)data {
	self = [super init];
	
	if (nil != self) {
        self.challengeData = data;
	}
	
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.navigationItem setHidesBackButton:YES];

    int i = (arc4random() % 4) + 1;
    NSString *patternName = [NSString stringWithFormat:@"Background%i", i];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:patternName]];
    
    BackgroundView *backView = [[BackgroundView alloc] initWithFrame:CGRectMake(MARGIN, self.navigationController.navigationBar.frame.size.height + MARGIN, self.view.frame.size.width - MARGIN*2, 0.0)];
    [self.view addSubview:backView];

    CGFloat totalWidth = backView.frame.size.width - (INNER_PADDING * 2) - 5.0;

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(backView.frame.origin.x + INNER_PADDING, backView.frame.origin.y + INNER_PADDING, totalWidth, 0.0)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont fontNamedLoRes9BoldOaklandWithSize:15.0];
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    titleLabel.numberOfLines = 0;
    titleLabel.text = _challengeData.title;
    [titleLabel sizeToFit];
    [self.view addSubview:titleLabel];
    
    UILabel *pointsLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x,
                                                                     titleLabel.frame.size.height + titleLabel.frame.origin.y + 2.0,
                                                                     totalWidth,
                                                                     0.0)];
    pointsLabel.backgroundColor = [UIColor clearColor];
    pointsLabel.textColor = [UIColor blueColor];
    pointsLabel.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:15.0];
    pointsLabel.text = [NSString stringWithFormat:@"%@ points", _challengeData.pointsString];
    [pointsLabel sizeToFit];
    [self.view addSubview:pointsLabel];
    
    UILabel *completionLabel = [[UILabel alloc] initWithFrame:CGRectMake(pointsLabel.frame.origin.x + 5.0,
                                                                         pointsLabel.frame.origin.y + pointsLabel.frame.size.height + 12.0,
                                                                         totalWidth,
                                                                         10.0)];
    completionLabel.backgroundColor = [UIColor clearColor];
    completionLabel.textColor = [UIColor whiteColor];
    completionLabel.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:13.0];
    int perc = _challengeData.completion * 100;
    completionLabel.text = [NSString stringWithFormat:@"%i%% completed", perc];
    [completionLabel sizeToFit];
    [self.view addSubview:completionLabel];
    
    UIView *completeMeterDone = [[UIView alloc] initWithFrame:CGRectMake(completionLabel.frame.origin.x - 5.0,
                                                                         completionLabel.frame.origin.y - 5.0,
                                                                         totalWidth * _challengeData.completion,
                                                                         completionLabel.frame.size.height + 10.0)];
    completeMeterDone.backgroundColor = [UIColor redColor];
    [self.view insertSubview:completeMeterDone belowSubview:completionLabel];
    
    UIView *completeMeterBack = [[UIView alloc] initWithFrame:CGRectMake(completeMeterDone.frame.origin.x + completeMeterDone.frame.size.width,
                                                                         completionLabel.frame.origin.y - 5.0,
                                                                         totalWidth * (1 - _challengeData.completion),
                                                                         completionLabel.frame.size.height + 10.0)];
    completeMeterBack.backgroundColor = [UIColor darkGrayColor];
    [self.view insertSubview:completeMeterBack belowSubview:completionLabel];
    
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(pointsLabel.frame.origin.x,
                                                                          completeMeterDone.frame.origin.y + completeMeterDone.frame.size.height + 10.0,
                                                                          totalWidth, 0.0)];
    descriptionLabel.backgroundColor = [UIColor clearColor];
    descriptionLabel.textColor = [UIColor blackColor];
    descriptionLabel.font = [UIFont fontNamedLoRes15BoldOaklandWithSize:14.0];
    descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.text = _challengeData.description;
    [descriptionLabel sizeToFit];
    [self.view addSubview:descriptionLabel];
    
    CGFloat height = descriptionLabel.frame.size.height + (descriptionLabel.frame.origin.y);
    CGRect frame;
    
    if ( [_challengeData.icon isEqualToString:@"twitter"] || [_challengeData.icon isEqualToString:@"profile"] ) {
        NSString *titleText = nil;
        if ( [_challengeData.icon isEqualToString:@"twitter"] ) titleText = @"Send Tweet";
        else titleText = @"Go to Profile";
            
        UIButton *challengeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        challengeBtn.frame = CGRectMake(descriptionLabel.frame.origin.x, height + 10.0, 100.0, 34.0);
        [challengeBtn setImage:[UIImage imageNamed:_challengeData.icon] forState:UIControlStateNormal];
        challengeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        challengeBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        if ( [_challengeData.icon isEqualToString:@"twitter"] ) [challengeBtn addTarget:self action:@selector(tweetBtnTouched) forControlEvents:UIControlEventTouchUpInside];
        else [challengeBtn addTarget:self action:@selector(profileBtnTouched) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *challengeLabel = [[UILabel alloc] initWithFrame:CGRectMake(33.0, 7.0, 0.0, 0.0)];
        challengeLabel.backgroundColor = [UIColor clearColor];
        challengeLabel.textColor = [UIColor blackColor];
        challengeLabel.font = [UIFont fontNamedLoRes15BoldOaklandWithSize:18.0];
        challengeLabel.text = titleText;
        [challengeLabel sizeToFit];
        
        [challengeBtn addSubview:challengeLabel];
        frame = challengeBtn.frame;
        frame.size.width = 33.0 + challengeLabel.frame.size.width + 5.0;
        challengeBtn.frame = frame;
        [self.view addSubview:challengeBtn];
        
        height = challengeBtn.frame.origin.y + challengeBtn.frame.size.height;
    }
    
    frame = backView.frame;
    frame.size.height = (height - backView.frame.origin.y) + INNER_PADDING + 5.0;
    backView.frame = frame;
    [backView setNeedsDisplay];

    
    backView = [[BackgroundView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y + frame.size.height + 10.0, frame.size.width, self.view.frame.size.height - (frame.origin.y + frame.size.height + 20.0))];
    [self.view addSubview:backView];
    
    UIView *rulesHolder = [[UIView alloc] initWithFrame:backView.frame];
    [self.view addSubview:rulesHolder];
    
    UILabel *rulesLabel = [[UILabel alloc] initWithFrame:CGRectMake(INNER_PADDING, INNER_PADDING, 1.0, 1.0)];
    rulesLabel.backgroundColor = [UIColor clearColor];
    rulesLabel.textColor = [UIColor blackColor];
    rulesLabel.font = [UIFont fontNamedLoRes9BoldOaklandWithSize:14.0];
    if ( [_challengeData.rulesArray count] > 1 ) rulesLabel.text = @"Rules:";
    else rulesLabel.text = @"Rule:";
    [rulesLabel sizeToFit];
    [rulesHolder addSubview:rulesLabel];

    UIView *blackLine = [[UIView alloc] initWithFrame:CGRectMake(0.0, rulesLabel.frame.origin.y + rulesLabel.frame.size.height + 5.0, rulesHolder.frame.size.width - 5.0, 2.0)];
    blackLine.backgroundColor = [UIColor blackColor];
    
    CGFloat maxHeight = rulesHolder.frame.size.height - blackLine.frame.origin.y - 5.0;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(blackLine.frame.origin.x,
                                                                              blackLine.frame.origin.y + 1,
                                                                              blackLine.frame.size.width,
                                                                              maxHeight)];
    
    CGFloat yPos = INNER_PADDING;
    UIColor *countColor = [UIColor blueColor];
    for ( NSDictionary *rule in _challengeData.rulesArray ) {
        int goal = [[rule objectForKey:@"goal"] intValue];
        int achieved = [[rule objectForKey:@"achieved"] intValue];
        NSString *countText = [NSString stringWithFormat:@"%i/%i", achieved, goal];
        NSString *content = [NSString stringWithFormat:@"%@ %@", countText, [rule objectForKey:@"description"]];
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:content];
        NSRange countRange = [content rangeOfString:countText];
        [attString addAttribute:NSForegroundColorAttributeName value:countColor range:countRange];
        
        UILabel *ruleLabel = [[UILabel alloc] initWithFrame:CGRectMake(INNER_PADDING, yPos, totalWidth, 0.0)];
        ruleLabel.backgroundColor = [UIColor clearColor];
        ruleLabel.textColor = [UIColor blackColor];
        ruleLabel.numberOfLines = 0;
        ruleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        ruleLabel.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:12.0];
        ruleLabel.attributedText = attString;
        
        [ruleLabel sizeToFit];
        [scrollView addSubview:ruleLabel];
        
        yPos += 8.0 + ruleLabel.frame.size.height;
    }
    
    frame = scrollView.frame;
    if ( yPos <= maxHeight - INNER_PADDING ) {
        frame.size.height = yPos;
        scrollView.frame = frame;
    }
    
    scrollView.contentSize = CGSizeMake(frame.size.width, yPos);
    
    frame = rulesHolder.frame;
    frame.size.height = scrollView.frame.origin.y + scrollView.frame.size.height + 8.0;
    rulesHolder.frame = frame;
    
    backView.frame = rulesHolder.frame;
    [backView setNeedsDisplay];
    
    
    [rulesHolder addSubview:scrollView];

    [rulesHolder addSubview:blackLine];
}

- (void)tweetBtnTouched {
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:@"Check out what I just got at Urban Outfitters #MYUOBUY. "];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)profileBtnTouched {
    ProfileViewController *profileVC = [[ProfileViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:profileVC];
    ViewController *revealController = (ViewController *)self.navigationController.parentViewController;
    [revealController setFrontViewController:navigationController animated:NO];
    
    
    /*
    ViewController *revealController = (ViewController *)self.navigationController.parentViewController;
    MenuViewController *menu = (MenuViewController *)revealController.rearViewController;
    [menu swapFrontView];
    */
    
    //ProfileViewController *profileVC = [[ProfileViewController alloc] init];
   //UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:profileVC];
   //[revealController setFrontViewController:navigationController animated:NO];
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

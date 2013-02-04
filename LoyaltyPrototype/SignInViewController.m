//
//  SignInViewController.m
//  LoyaltyPrototype
//
//  Created by Jason Grandelli on 1/29/13.
//  Copyright (c) 2013 URBN. All rights reserved.
//

#import "SignInViewController.h"
#import "NavBarItemsViewController.h"
#import "BackgroundView.h"
#import "UIFont+UrbanAdditions.h"
#import "AuthenticateViewController.h"

@interface SignInViewController ()

@property (nonatomic, strong) UIView *titleBar;
@property (nonatomic, strong) UIView *promoArea;

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"splashBK"]];
    
    NavBarItemsViewController *navBarItems = [[NavBarItemsViewController alloc] init];
    navBarItems.pageName = @"Urban Outfitters";
    [navBarItems.view setFrame:self.navigationController.navigationBar.bounds];
    [self.navigationController.navigationBar addSubview:navBarItems.view];
    
    
    /*
    BackgroundView *promoBack = [[BackgroundView alloc] initWithFrame:CGRectMake(15.0, self.navigationController.navigationBar.frame.size.height + 15.0, self.view.frame.size.width - 30.0, 200.0)];
    [self.view addSubview:promoBack];
    NSLog(@"promo area = %@", NSStringFromCGSize(promoBack.frame.size));
    */
    
    UIButton *signInBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    signInBtn.frame = CGRectMake(24.0, 310.0, self.view.frame.size.width - 48.0, 44.0);
    [signInBtn addTarget:self action:@selector(signIn) forControlEvents:UIControlEventTouchUpInside];
    
    BackgroundView *buttonBack = [[BackgroundView alloc] initWithFrame:CGRectMake(0.0, 0.0, signInBtn.frame.size.width, signInBtn.frame.size.height)];
    buttonBack.userInteractionEnabled = NO;
    [signInBtn addSubview:buttonBack];
    
    UILabel *buttonText = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 0.0, 0.0)];
    buttonText.backgroundColor = [UIColor clearColor];
    buttonText.textColor = [UIColor blackColor];
    buttonText.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:16.0];
    buttonText.text = @"Sign In";
    [buttonText sizeToFit];
    [signInBtn addSubview:buttonText];

    UIImageView *arrowImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_right"]];
    arrowImg.frame = CGRectMake(signInBtn.frame.size.width - 28.0, 14.0, 10.0, 10.0);
    [signInBtn addSubview:arrowImg];

    [self.view addSubview:signInBtn];


    UIButton *signUpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    signUpBtn.frame = CGRectMake(24.0, signInBtn.frame.origin.y + signInBtn.frame.size.height + 10.0, signInBtn.frame.size.width, 44.0);
    [signUpBtn addTarget:self action:@selector(signUp) forControlEvents:UIControlEventTouchUpInside];

    buttonBack = [[BackgroundView alloc] initWithFrame:CGRectMake(0.0, 0.0, signUpBtn.frame.size.width, signUpBtn.frame.size.height)];
    buttonBack.userInteractionEnabled = NO;
    [signUpBtn addSubview:buttonBack];
    
    buttonText = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 0.0, 0.0)];
    buttonText.backgroundColor = [UIColor clearColor];
    buttonText.textColor = [UIColor blackColor];
    buttonText.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:16.0];
    buttonText.text = @"Create an Account";
    [buttonText sizeToFit];
    [signUpBtn addSubview:buttonText];
    
    arrowImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_right"]];
    arrowImg.frame = CGRectMake(signUpBtn.frame.size.width - 28.0, 14.0, 10.0, 10.0);
    [signUpBtn addSubview:arrowImg];

    [self.view addSubview:signUpBtn];
}

- (void)signIn {
    AuthenticateViewController *authVC = [[AuthenticateViewController alloc] init];
    authVC.hasAccount = YES;
    [self.navigationController pushViewController:authVC animated:YES];
}

- (void)signUp {
    AuthenticateViewController *authVC = [[AuthenticateViewController alloc] init];
    authVC.hasAccount = NO;
    [self.navigationController pushViewController:authVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

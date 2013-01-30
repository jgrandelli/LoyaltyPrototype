//
//  AuthenticateViewController.m
//  LoyaltyPrototype
//
//  Created by Jason Grandelli on 1/30/13.
//  Copyright (c) 2013 URBN. All rights reserved.
//

#import "AuthenticateViewController.h"
#import "BackgroundView.h"
#import "UIFont+UrbanAdditions.h"
#import "StatusViewController.h"
#import "ViewController.h"
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import "UserData.h"

@interface AuthenticateViewController ()

@property (nonatomic, strong) UIButton *maleBtn;
@property (nonatomic, strong) UIButton *femaleBtn;

@end

@implementation AuthenticateViewController

#define PADDING 5.0f

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.navigationItem setHidesBackButton:YES];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"SplashBackground"]];

    if ( self.hasAccount ) [self showSignIn];
    else [self showSignUp];
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

- (void)showSignIn {
    BackgroundView *formBack = [[BackgroundView alloc] initWithFrame:CGRectMake(15.0, 150.0, self.view.frame.size.width - 30.0, 44.0)];
    [self.view addSubview:formBack];

    UILabel *userName = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 0.0, 0.0)];
    userName.backgroundColor = [UIColor clearColor];
    userName.textColor = [UIColor blackColor];
    userName.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:16.0];
    userName.text = @"Username: Erez";
    [userName sizeToFit];
    [formBack addSubview:userName];
    
    formBack = [[BackgroundView alloc] initWithFrame:CGRectMake(15.0, formBack.frame.origin.y + formBack.frame.size.height + PADDING, self.view.frame.size.width - 30.0, 44.0)];
    [self.view addSubview:formBack];
    
    UITextField *password = [[UITextField alloc] initWithFrame:CGRectMake(10.0, 9.0, formBack.frame.size.width - 31.0, formBack.frame.size.height - 20.0)];
    password.backgroundColor = [UIColor clearColor];
    password.textColor = [UIColor blackColor];
    password.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:16.0];
    password.secureTextEntry = YES;
    password.text = @"123456";
    password.userInteractionEnabled = NO;
    [formBack addSubview:password];
    
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    submitBtn.frame = CGRectMake(15.0, formBack.frame.origin.y + formBack.frame.size.height + 25.0, formBack.frame.size.width, 44.0);
    [submitBtn addTarget:self action:@selector(submitBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:submitBtn];
    
    BackgroundView *submitBox = [[BackgroundView alloc] initWithFrame:CGRectMake(0.0, 0.0, submitBtn.frame.size.width, submitBtn.frame.size.height) color:[UIColor blueColor] borderColor:[UIColor blackColor]];
    submitBox.userInteractionEnabled = NO;
    [submitBtn addSubview:submitBox];
    
    UILabel *submitLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, submitBox.frame.size.width - 5.0, submitBox.frame.size.height - 5.0)];
    submitLabel.backgroundColor = [UIColor clearColor];
    submitLabel.textColor = [UIColor whiteColor];
    submitLabel.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:18.0];
    submitLabel.textAlignment = NSTextAlignmentCenter;
    submitLabel.text = @"SIGN IN";
    [submitBtn addSubview:submitLabel];
}

- (void)showSignUp {
    //Username
    BackgroundView *formBack = [[BackgroundView alloc] initWithFrame:CGRectMake(15.0, self.navigationController.navigationBar.frame.size.height + 15.0, self.view.frame.size.width - 30.0, 44.0)];
    [self.view addSubview:formBack];
    
    UILabel *inputText = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 0.0, 0.0)];
    inputText.backgroundColor = [UIColor clearColor];
    inputText.textColor = [UIColor blackColor];
    inputText.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:16.0];
    inputText.text = @"Username: Erez";
    [inputText sizeToFit];
    [formBack addSubview:inputText];

    
    //Email
    formBack = [[BackgroundView alloc] initWithFrame:CGRectMake(15.0, formBack.frame.origin.y + formBack.frame.size.height + PADDING, formBack.frame.size.width, 44.0)];
    [self.view addSubview:formBack];
    
    inputText = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 0.0, 0.0)];
    inputText.backgroundColor = [UIColor clearColor];
    inputText.textColor = [UIColor blackColor];
    inputText.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:16.0];
    inputText.text = @"Email: erez@uoloyalty.com";
    [inputText sizeToFit];
    [formBack addSubview:inputText];
    
    
    //Password
    formBack = [[BackgroundView alloc] initWithFrame:CGRectMake(15.0, formBack.frame.origin.y + formBack.frame.size.height + PADDING, formBack.frame.size.width, 44.0)];
    [self.view addSubview:formBack];
    
    inputText = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 0.0, 0.0)];
    inputText.backgroundColor = [UIColor clearColor];
    inputText.textColor = [UIColor blackColor];
    inputText.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:16.0];
    inputText.text = @"Password: 123456";
    [inputText sizeToFit];
    [formBack addSubview:inputText];

    
    //First Name
    formBack = [[BackgroundView alloc] initWithFrame:CGRectMake(15.0, formBack.frame.origin.y + formBack.frame.size.height + PADDING, formBack.frame.size.width, 44.0)];
    [self.view addSubview:formBack];
    
    inputText = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 0.0, 0.0)];
    inputText.backgroundColor = [UIColor clearColor];
    inputText.textColor = [UIColor blackColor];
    inputText.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:16.0];
    inputText.text = @"First Name: Evan";
    [inputText sizeToFit];
    [formBack addSubview:inputText];

    
    //Last Name
    formBack = [[BackgroundView alloc] initWithFrame:CGRectMake(15.0, formBack.frame.origin.y + formBack.frame.size.height + PADDING, formBack.frame.size.width, 44.0)];
    [self.view addSubview:formBack];
    
    inputText = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 0.0, 0.0)];
    inputText.backgroundColor = [UIColor clearColor];
    inputText.textColor = [UIColor blackColor];
    inputText.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:16.0];
    inputText.text = @"Last Name: Rezai";
    [inputText sizeToFit];
    [formBack addSubview:inputText];
    
    
    //Gender
    formBack = [[BackgroundView alloc] initWithFrame:CGRectMake(15.0, formBack.frame.origin.y + formBack.frame.size.height + PADDING, formBack.frame.size.width, 44.0)];
    [self.view addSubview:formBack];
    
    inputText = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 0.0, 0.0)];
    inputText.backgroundColor = [UIColor clearColor];
    inputText.textColor = [UIColor blackColor];
    inputText.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:16.0];
    inputText.text = @"Gender?";
    [inputText sizeToFit];
    [formBack addSubview:inputText];
    
    UIImage *radio = [UIImage imageNamed:@"radioBtn"];
    UIImage *radioSelected = [UIImage imageNamed:@"radioBtn-selected"];
    
    self.maleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _maleBtn.frame = CGRectMake(10.0, inputText.frame.origin.y + inputText.frame.size.height + 8.0, 30.0, 30.0);
    _maleBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_maleBtn setImage:radio forState:UIControlStateNormal];
    [_maleBtn setImage:radioSelected forState:UIControlStateSelected];
    _maleBtn.tag = 10;
    [_maleBtn addTarget:self action:@selector(genderRadioSelected:) forControlEvents:UIControlEventTouchUpInside];
    [formBack addSubview:_maleBtn];

    UILabel *maleLabel = [[UILabel alloc] initWithFrame:CGRectMake(38.0, 5.0, 0.0, 0.0)];
    maleLabel.backgroundColor = [UIColor clearColor];
    maleLabel.textColor = [UIColor blackColor];
    maleLabel.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:16.0];
    maleLabel.text = @"Male";
    maleLabel.tag = 11;
    [maleLabel sizeToFit];
    [_maleBtn addSubview:maleLabel];
    
    CGRect frame = _maleBtn.frame;
    frame.size.width = maleLabel.frame.origin.x + maleLabel.frame.size.width;
    _maleBtn.frame = frame;
    
    self.femaleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _femaleBtn.frame = CGRectMake(48.0 + maleLabel.frame.size.width + 25.0, inputText.frame.origin.y + inputText.frame.size.height + 8.0, 30.0, 30.0);
    _femaleBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_femaleBtn setImage:radio forState:UIControlStateNormal];
    [_femaleBtn setImage:radioSelected forState:UIControlStateSelected];
    _femaleBtn.tag = 20;
    [_femaleBtn addTarget:self action:@selector(genderRadioSelected:) forControlEvents:UIControlEventTouchUpInside];
    [formBack addSubview:_femaleBtn];
    
    UILabel *femaleLabel = [[UILabel alloc] initWithFrame:CGRectMake(38.0, 5.0, 0.0, 0.0)];
    femaleLabel.backgroundColor = [UIColor clearColor];
    femaleLabel.textColor = [UIColor blackColor];
    femaleLabel.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:16.0];
    femaleLabel.text = @"Female";
    femaleLabel.tag = 21;
    [femaleLabel sizeToFit];
    [_femaleBtn addSubview:femaleLabel];
   
    frame = _femaleBtn.frame;
    frame.size.width = femaleLabel.frame.origin.x + femaleLabel.frame.size.width;
    _femaleBtn.frame = frame;
    
    [self performSelector:@selector(genderRadioSelected:) withObject:_femaleBtn];
    
    frame = formBack.frame;
    frame.size.height = _maleBtn.frame.origin.y + _maleBtn.frame.size.height + 15.0;
    formBack.frame = frame;
    [formBack setNeedsDisplay];
    
    
    
    
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    submitBtn.frame = CGRectMake(15.0, formBack.frame.origin.y + formBack.frame.size.height + 15.0, formBack.frame.size.width, 44.0);
    [submitBtn addTarget:self action:@selector(submitBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:submitBtn];
    
    BackgroundView *submitBox = [[BackgroundView alloc] initWithFrame:CGRectMake(0.0, 0.0, submitBtn.frame.size.width, submitBtn.frame.size.height) color:[UIColor blueColor] borderColor:[UIColor blackColor]];
    submitBox.userInteractionEnabled = NO;
    [submitBtn addSubview:submitBox];
    
    UILabel *submitLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, submitBox.frame.size.width - 5.0, submitBox.frame.size.height - 5.0)];
    submitLabel.backgroundColor = [UIColor clearColor];
    submitLabel.textColor = [UIColor whiteColor];
    submitLabel.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:18.0];
    submitLabel.textAlignment = NSTextAlignmentCenter;
    submitLabel.text = @"SIGN UP";
    [submitBtn addSubview:submitLabel];
}

- (void)submitBtnPressed {
    if ( !_hasAccount ) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"\"MYUO\" Would Like to Send You Push Notifications" message:@"Notifications may include alerts, sounds and icon badges. These can be configured in Settings." delegate:self cancelButtonTitle:@"Don't Allow" otherButtonTitles:@"OK", nil];
        [alertView show];
    }
    else [self loadStatus];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ( buttonIndex == 1 ) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        NSString *baseURL = @"https://sandbox.bunchball.net/nitro/json?tags=App%5Fdownload&storeResponse=false&asyncToken=&newsfeed=&metadata=&competitionInstanceId=&value=0&target=&userId=16&method=user%2ElogAction&sessionKey=";
        NSString *urlString = [NSString stringWithFormat:@"%@%@", baseURL, [[UserData sharedInstance] sessionKey]];
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *req = [[NSURLRequest alloc] initWithURL:url];
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:req
                                                                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                                [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                                                                [self loadStatus];
                                                                                            }
                                                                                            failure:nil];
        [operation start];
    }
    else [self loadStatus];
}

- (void)loadStatus {
    StatusViewController *statusVC = [[StatusViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:statusVC];
    ViewController *revealController = (ViewController *)self.navigationController.parentViewController;
    [revealController setFrontViewController:navigationController animated:NO];
}

- (void)genderRadioSelected:(id)sender {
    if ( [sender tag] == 10 ) {
        _maleBtn.selected = YES;
        UILabel *label = (UILabel *)[_maleBtn viewWithTag:11];
        label.textColor = [UIColor blueColor];
        
        _femaleBtn.selected = NO;
        label = (UILabel *)[_femaleBtn viewWithTag:21];
        label.textColor = [UIColor blackColor];
    }
    else {
        _maleBtn.selected = NO;
        UILabel *label = (UILabel *)[_maleBtn viewWithTag:11];
        label.textColor = [UIColor blackColor];
        
        _femaleBtn.selected = YES;
        label = (UILabel *)[_femaleBtn viewWithTag:21];
        label.textColor = [UIColor blueColor];
    }
}

- (void)backBtnPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

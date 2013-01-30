//
//  CheckInViewController.m
//  LoyaltyPrototype
//
//  Created by Jason Grandelli on 1/23/13.
//  Copyright (c) 2013 URBN. All rights reserved.
//

#import "CheckInViewController.h"
#import "NavBarItemsViewController.h"
#import "UIFont+UrbanAdditions.h"
#import "BackgroundView.h"
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import "UserData.h"
#import "VenueListViewController.h"

#import <Social/Social.h>
#import <Accounts/ACAccountType.h>
#import <Accounts/ACAccountCredential.h>
#import <Accounts/ACAccountStore.h>

#import <FacebookSDK/FacebookSDK.h>
#import <Twitter/Twitter.h>

#import "AppDelegate.h"

@interface CheckInViewController ()

@property (nonatomic, strong) UIButton *checkinBtn;
@property (nonatomic, strong) UITextField *messageTextField;
@property (nonatomic, strong) UIButton *fbButton;
@property (nonatomic, strong) UIButton *twButton;

@property (strong, nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic) ACAccount *facebookAccount;
@property (strong, nonatomic) NSMutableDictionary *postParams;

@end

@implementation CheckInViewController

#define MARGIN 15.0f
#define PADDING 10.0f
#define BASE_URL @"https://sandbox.bunchball.net/nitro/json?userId=16&value=0&storeResponse=false&newsfeed=&metadata=&competitionInstanceId=&method=user.logAction&asyncToken=&target="

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.venueData = nil;
    
    int i = (arc4random() % 4) + 1;
    NSString *patternName = [NSString stringWithFormat:@"Background%i", i];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:patternName]];
    
    NavBarItemsViewController *navBarItems = [[NavBarItemsViewController alloc] init];
    navBarItems.pageName = @"Check-In";
    [navBarItems.view setFrame:self.navigationController.navigationBar.bounds];
    [self.navigationController.navigationBar addSubview:navBarItems.view];
    
    if ([self.navigationController.parentViewController respondsToSelector:@selector(revealGesture:)] &&
        [self.navigationController.parentViewController respondsToSelector:@selector(revealToggle:)])
    {
        UIPanGestureRecognizer *navigationBarPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self.navigationController.parentViewController action:@selector(revealGesture:)];
		[self.navigationController.navigationBar addGestureRecognizer:navigationBarPanGestureRecognizer];
	}
    
    self.checkinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _checkinBtn.frame = CGRectMake(MARGIN, self.navigationController.navigationBar.frame.size.height + MARGIN, self.view.frame.size.width - MARGIN*2, 44.0);
    [_checkinBtn addTarget:self action:@selector(checkinBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_checkinBtn];

    BackgroundView *backView = [[BackgroundView alloc] initWithFrame:_checkinBtn.bounds];
    backView.userInteractionEnabled = NO;
    [_checkinBtn addSubview:backView];
    
    UIImage *iconImg = [UIImage imageNamed:@"store_locator"];
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(8.0, 8.0, 22.0, 22.0)];
    [iconView setImage:[self getImageWithUnsaturatedPixelsOfImage:iconImg]];
    iconView.tag = 10;
    [_checkinBtn addSubview:iconView];
    
    UILabel *btnLabel = [[UILabel alloc] initWithFrame:CGRectMake(iconView.frame.origin.x + iconView.frame.size.width + 5.0, PADDING + 1, 0.0, 0.0)];
    btnLabel.backgroundColor = [UIColor clearColor];
    btnLabel.textColor = [UIColor darkGrayColor];
    btnLabel.font = [UIFont fontNamedLoRes15BoldOaklandWithSize:16.0];
    btnLabel.text = @"Name this location";
    [btnLabel sizeToFit];
    btnLabel.tag = 11;
    [_checkinBtn addSubview:btnLabel];
    
    UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(_checkinBtn.frame.size.width - 28.0, 15.0, 10.0, 10.0)];
    [arrow setImage:[UIImage imageNamed:@"arrow_right"]];
    arrow.alpha = 0.7;
    [_checkinBtn addSubview:arrow];

    BackgroundView *shareBox = [[BackgroundView alloc] initWithFrame:CGRectMake(MARGIN,
                                                                                _checkinBtn.frame.origin.y + _checkinBtn.frame.size.height + MARGIN,
                                                                                self.view.frame.size.width - MARGIN*2,
                                                                                100.0)];
    [self.view addSubview:shareBox];
    
    UILabel *shareOnLabel = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, PADDING, 0.0, 0.0)];
    shareOnLabel.backgroundColor = [UIColor clearColor];
    shareOnLabel.textColor = [UIColor blackColor];
    shareOnLabel.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:16.0];
    shareOnLabel.text = @"Share on:";
    [shareOnLabel sizeToFit];
    [shareBox addSubview:shareOnLabel];
    
    UIImage *fbImg = [UIImage imageNamed:@"share_facebookBtn"];
    self.fbButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _fbButton.frame = CGRectMake(PADDING, shareOnLabel.frame.origin.y + shareOnLabel.frame.size.height + 10.0, fbImg.size.width, fbImg.size.height);
    [_fbButton setImage:fbImg forState:UIControlStateNormal];
    [_fbButton setImage:[UIImage imageNamed:@"share_facebookBtn_selected"] forState:UIControlStateSelected];
    [_fbButton addTarget:self action:@selector(shareBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    [shareBox addSubview:_fbButton];

    self.twButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _twButton.frame = CGRectMake(_fbButton.frame.origin.x + _fbButton.frame.size.width + 15.0, _fbButton.frame.origin.y, fbImg.size.width, fbImg.size.height);
    [_twButton setImage:[UIImage imageNamed:@"share_twitterBtn"] forState:UIControlStateNormal];
    [_twButton setImage:[UIImage imageNamed:@"share_twitterBtn_selected"] forState:UIControlStateSelected];
    [_twButton addTarget:self action:@selector(shareBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    [shareBox addSubview:_twButton];
    
    self.messageTextField = [[UITextField alloc] initWithFrame:CGRectMake(PADDING, _fbButton.frame.origin.y + _fbButton.frame.size.height + 10.0, shareBox.frame.size.width - PADDING*2 - 5.0, 100.0)];
    _messageTextField.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1];
    _messageTextField.font = [UIFont fontNamedLoRes15BoldOaklandWithSize:14.0];
    _messageTextField.textColor = [UIColor blackColor];
    _messageTextField.borderStyle = UITextBorderStyleLine;
    _messageTextField.text = @"Write your message...";
    _messageTextField.delegate = self;
    [shareBox addSubview:_messageTextField];

    CGRect frame = shareBox.frame;
    frame.size.height = _messageTextField.frame.origin.y + _messageTextField.frame.size.height + PADDING + 8.0;
    shareBox.frame = frame;
    [shareBox setNeedsDisplay];
    
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    submitBtn.frame = CGRectMake(MARGIN, shareBox.frame.origin.y + shareBox.frame.size.height + MARGIN, shareBox.frame.size.width, 44.0);
    [submitBtn addTarget:self action:@selector(submitBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:submitBtn];
    
    BackgroundView *submitOver = [[BackgroundView alloc] initWithFrame:CGRectMake(0.0, 0.0, submitBtn.frame.size.width, submitBtn.frame.size.height) color:[UIColor grayColor] borderColor:[UIColor grayColor]];
    submitOver.userInteractionEnabled = NO;
    [submitBtn addSubview:submitOver];

    BackgroundView *submitBox = [[BackgroundView alloc] initWithFrame:CGRectMake(0.0, 0.0, submitBtn.frame.size.width, submitBtn.frame.size.height) color:[UIColor blueColor] borderColor:[UIColor blackColor]];
    submitBox.tag = 1000;
    [submitBtn addSubview:submitBox];
    
    
    UILabel *submitLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, submitBox.frame.size.width - 5.0, submitBox.frame.size.height - 5.0)];
    submitLabel.backgroundColor = [UIColor clearColor];
    submitLabel.textColor = [UIColor whiteColor];
    submitLabel.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:18.0];
    submitLabel.textAlignment = NSTextAlignmentCenter;
    submitLabel.text = @"SUBMIT";
    [submitBtn addSubview:submitLabel];

    if ( [CLLocationManager locationServicesEnabled] == NO) {
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"You currently have all location services for this device disabled. If you proceed, you will be asked to confirm whether location services should be reenabled." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [servicesDisabledAlert show];
    }
}

- (void)shareBtnTouched:(id)sender {
    UIButton *btn = sender;
    btn.selected = !btn.selected;
    
    if ( _fbButton.selected ) {
        [self checkFacebook];
    }
}

- (void)checkFacebook {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if ( !FBSession.activeSession.isOpen ) {
        [appDelegate openSessionWithAllowLoginUI:YES];
    }
    else {
        NSLog(@"session is already open!");
    }
}

#pragma mark UITextFieldDelegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ( [_messageTextField.text isEqualToString:@"Write your message..."] ) _messageTextField.text = @"";
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ( [_messageTextField.text isEqualToString:@""] ) _messageTextField.text = @"Write your message...";
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_messageTextField resignFirstResponder];
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
    
    BackgroundView *submitBox = (BackgroundView *)[self.view viewWithTag:1000];
    
    if ( _venueData ) {
        UIImageView *iconImg = (UIImageView *)[self.view viewWithTag:10];
        [iconImg setImage:[UIImage imageNamed:@"store_locator"]];
        
        UILabel *btnLabel = (UILabel *)[self.view viewWithTag:11];
        btnLabel.textColor = [UIColor blackColor];
        CGRect frame = btnLabel.frame;
        frame.size.width = (self.view.frame.size.width - MARGIN*2) - btnLabel.frame.origin.x - PADDING - 25.0;
        btnLabel.frame = frame;
        btnLabel.text = [_venueData objectForKey:@"venueName"];
        
        submitBox.alpha = 1.0;
        submitBox.userInteractionEnabled = NO;
    }
    else {
        submitBox.alpha = 0.4;
        submitBox.userInteractionEnabled = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    UIButton *btn = (UIButton *)[self.navigationController.navigationBar viewWithTag:1];
    [btn removeFromSuperview];
    
    btn = (UIButton *)[self.navigationController.navigationBar viewWithTag:2];
    [btn removeFromSuperview];
}


- (void)checkinBtnPressed {
    VenueListViewController *venueList = [[VenueListViewController alloc] init];
    [self.navigationController pushViewController:venueList animated:YES];
}

- (void)submitBtnPressed {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *tagString = [NSString stringWithFormat:@"&tags=%@|%@|%@", [_venueData objectForKey:@"venueName"], [_venueData objectForKey:@"venueLocation"], [_venueData objectForKey:@"venueID"]];
    tagString = [tagString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@%@&sessionKey=%@", BASE_URL, tagString, [[UserData sharedInstance] sessionKey]];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    NSString *message = nil;
    if ( [_messageTextField.text isEqualToString:@""] || [_messageTextField.text isEqualToString:@"Write your message..."] ) {
        message = [NSString stringWithFormat:@"I'm hanging out @ %@", [_venueData objectForKey:@"venueName"]];
    }
    else {
        message = [NSString stringWithFormat:@"%@ @ %@", _messageTextField.text, [_venueData objectForKey:@"venueName"]];
    }

    if ( _fbButton.selected ) {
        self.postParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"Urabn Outfitters Loyalty", @"name",
                           message, @"message",
                           nil];
        
        if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
            [FBSession.activeSession reauthorizeWithPublishPermissions: [NSArray arrayWithObject:@"publish_actions"]
                                                       defaultAudience:FBSessionDefaultAudienceFriends
                                                     completionHandler:^(FBSession *session, NSError *error) {
                                                         if (!error) {
                                                             // If permissions granted, publish the story
                                                             [self publishToFacebook];
                                                         }
                                                     }];
        }
        else {
            // If permissions present, publish the story
            [self publishToFacebook];
        }
    }
    
    if ( _twButton.selected ) {
        [self publishToTwitterWithMessage:(NSString *)message];
    }
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:req
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [self submitSuccessWithData:JSON];
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            [self submitError];
                                                                                        }];
    [operation start];
}

- (void)publishToFacebook {
    [FBRequestConnection startWithGraphPath:@"me/feed"
                                 parameters:self.postParams
                                 HTTPMethod:@"POST"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                          }];
}

- (void)publishToTwitterWithMessage:(NSString *)message {
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if (granted == YES) {
            NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
            
            if ([arrayOfAccounts count] > 0) {
                ACAccount *acct = [arrayOfAccounts objectAtIndex:0];
                
                
                NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1/statuses/update.json"];
                
                NSDictionary *params = @{@"status":message};
                
                SLRequest *slRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                          requestMethod:SLRequestMethodPOST
                                                                    URL:url
                                                             parameters:params];
                
                [slRequest setAccount:acct];
                [slRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                }];
            }
        }
    }];
}

- (void)submitSuccessWithData:(NSDictionary *)JSON {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    //if ( [[[JSON objectForKey:@"Nitro"] objectForKey:@"res"] isEqualToString:@"ok"] ) {
        UIImageView *iconImg = (UIImageView *)[self.view viewWithTag:10];
        [iconImg setImage:[self getImageWithUnsaturatedPixelsOfImage:[UIImage imageNamed:@"store_locator@2x"]]];
        
        UILabel *btnLabel = (UILabel *)[self.view viewWithTag:11];
        btnLabel.text = @"Name this location";
        btnLabel.textColor = [UIColor darkGrayColor];
        
        _messageTextField.text = @"Write your message...";
        _fbButton.selected = NO;
        _twButton.selected = NO;

        UIView *submitBox = [self.view viewWithTag:1000];
        submitBox.alpha = 0.4;
        submitBox.userInteractionEnabled = YES;
    //}
    //else {
        //[self showErrorAlert:[[[JSON objectForKey:@"Nitro"] objectForKey:@"Error"] objectForKey:@"Message"]];
    //}
}

- (void)submitError {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self showErrorAlert:@"Sorry there was an error."];
}

- (void)showErrorAlert:(NSString *)message {
    message = [message stringByAppendingString:@" Please try again."];
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Something went wrong" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

-(UIImage *)getImageWithUnsaturatedPixelsOfImage:(UIImage *)image {
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

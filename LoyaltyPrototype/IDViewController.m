//
//  IDViewController.m
//  LoyaltyPrototype
//
//  Created by Jason Grandelli on 1/22/13.
//  Copyright (c) 2013 URBN. All rights reserved.
//

#import "IDViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "NavBarItemsViewController.h"
#import "BackgroundView.h"
#import "UIFont+UrbanAdditions.h"

@interface IDViewController ()

@property (nonatomic, strong) UIView *userID;

@end

@implementation IDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    int i = (arc4random() % 9) + 1;
    NSString *patternName = [NSString stringWithFormat:@"Background%i", i];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:patternName]];
    
    NavBarItemsViewController *navBarItems = [[NavBarItemsViewController alloc] init];
    navBarItems.pageName = @"MYUO ID";
    [navBarItems.view setFrame:self.navigationController.navigationBar.bounds];
    [self.navigationController.navigationBar addSubview:navBarItems.view];
    
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
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    
    NSArray *arr = @[@"alien", @"hamburger", @"lips", @"skull"];
    
    CGFloat yPos = (self.view.frame.size.height*.5 - (self.view.frame.size.width - 30.0)*.5);
    for ( int i = 0; i < [arr count]; ++i ) {
        UIButton *qrBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        qrBtn.frame = CGRectMake(i*scrollView.frame.size.width + 15.0, yPos, self.view.frame.size.width - 30.0, self.view.frame.size.width - 30.0);
        [qrBtn addTarget:self action:@selector(qrBtnTapped:) forControlEvents:UIControlEventTouchUpInside];

        BackgroundView *backView = [[BackgroundView alloc] initWithFrame:CGRectMake(0.0, 0.0, qrBtn.frame.size.width, qrBtn.frame.size.height )];
        backView.userInteractionEnabled = NO;
        
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(3.0, 3.0, backView.frame.size.width - 11.0, backView.frame.size.height - 11.0)];
        [img setImage:[UIImage imageNamed:[NSString stringWithFormat:@"myuoid_%@", [arr objectAtIndex:i]]]];
        [backView addSubview:img];
        
        [qrBtn addSubview:backView];
        
        [scrollView addSubview:qrBtn];
    }
    
    scrollView.contentSize = CGSizeMake([arr count] * self.view.frame.size.width, self.view.frame.size.height);

    [self.view addSubview:scrollView];
    
    self.userID = [[UIView alloc] initWithFrame:CGRectMake(15.0, yPos + (self.view.frame.size.width - 30.0) + 15.0, self.view.frame.size.width - 30.0, 40.0)];
    [self.view addSubview:_userID];
    
    BackgroundView *backView = [[BackgroundView alloc] initWithFrame:_userID.bounds];
    [_userID addSubview:backView];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 8.0, 0.0, 0.0)];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.textColor = [UIColor blackColor];
    lbl.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:16.0];
    lbl.text = @"ID #32168735";
    CGRect frame = lbl.frame;
    [lbl sizeToFit];
    frame.size.width = lbl.frame.size.width;
    frame.origin.x = (backView.frame.size.width - 11.0)*.5 - lbl.frame.size.width*.5;
    frame.size.height = lbl.frame.size.height;
    lbl.frame = frame;
    [_userID addSubview:lbl];
    
    _userID.alpha = 0.0;
}

- (void)qrBtnTapped:(id)sender {
    CGFloat a = 0.0;
    if ( _userID.alpha == 0.0 ) a = 1.0;
    
    [UIView animateWithDuration:.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                         _userID.alpha = a;
                     }
                     completion:^(BOOL finished) {
                     }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

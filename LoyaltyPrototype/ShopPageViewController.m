//
//  ShopPageViewController.m
//  LoyaltyPrototype
//
//  Created by Jason Grandelli on 1/16/13.
//  Copyright (c) 2013 URBN. All rights reserved.
//

#import "ShopPageViewController.h"
#import "NavBarItemsViewController.h"
#import "UIFont+UrbanAdditions.h"
#import "BackgroundView.h"

@interface ShopPageViewController ()

@property (nonatomic, strong) UIView *titleBar;
@property (nonatomic, strong) UIView *promoArea;

@end

@implementation ShopPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Background3"]];

    NavBarItemsViewController *navBarItems = [[NavBarItemsViewController alloc] init];
    navBarItems.pageType = @"shopping";
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
    
    UIImage *rightImg = [UIImage imageNamed:@"cartBtn"];
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(self.view.frame.size.width - rightImg.size.width - 10.0, 5.0, rightImg.size.width, rightImg.size.height);
    [rightBtn setImage:rightImg forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:rightBtn];

    
    self.titleBar = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, 34.0)];
    _titleBar.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:_titleBar];
    
    UIView *blackBar = [[UIView alloc] initWithFrame:CGRectMake(0.0, _titleBar.frame.size.height - 2.0, self.view.frame.size.width, 2.0)];
    blackBar.backgroundColor = [UIColor blackColor];
    [_titleBar addSubview:blackBar];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, _titleBar.frame.size.width, _titleBar.frame.size.height)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontNamedLoRes22BoldOaklandWithSize:26.0];
    titleLabel.tag = 1;
    [_titleBar addSubview:titleLabel];
    
    UIView *promoBack = [[BackgroundView alloc] initWithFrame:CGRectMake(15.0, _titleBar.frame.origin.y + _titleBar.frame.size.height + 15.0, self.view.frame.size.width - 30.0, 200.0)];
    [self.view addSubview:promoBack];
    
    UIImageView *promoImg = [[UIImageView alloc] initWithFrame:CGRectMake(promoBack.frame.origin.x + 3.0, promoBack.frame.origin.y + 3.0, 279.0, 189.0)];
    promoImg.tag = 2;
    [self.view addSubview:promoImg];
    
    CGFloat yPos = promoBack.frame.origin.y + promoBack.frame.size.height + 20.0;
    NSArray *arr = @[@"Collections", @"New Arrivals", @"Spring Preview", @"Tops", @"Outerwear", @"Shoes", @"Accessories"];
    for ( int i = 0; i < 6; ++i ) {
        BackgroundView *catBack = [[BackgroundView alloc] initWithFrame:CGRectMake(15.0, yPos, promoBack.frame.size.width, 40.0)];
        [self.view addSubview:catBack];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 2.0, catBack.frame.size.width, catBack.frame.size.height - 11.0)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:16.0];
        label.text = [arr objectAtIndex:i];
        [catBack addSubview:label];
        
        yPos += catBack.frame.size.height + 10.0;
    }
    
    [self updateViewWithTitle:_department];
}

- (void)updateViewWithTitle:(NSString *)title {
    UILabel *titleLabel = (UILabel *)[_titleBar viewWithTag:1];
    titleLabel.text = title;
    
    NSString *imgName = [NSString stringWithFormat:@"%@Promo", [title lowercaseString]];
    UIImageView *promoImg = (UIImageView *)[self.view viewWithTag:2];
    [promoImg setImage:[UIImage imageNamed:imgName]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

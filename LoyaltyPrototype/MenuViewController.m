//
//  MenuViewController.m
//  LoyaltyPrototype
//
//  Created by Jason Grandelli on 12/5/12.
//  Copyright (c) 2012 URBN. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MenuViewController.h"
#import "UIColor+ColorConstants.h"
#import "ViewController.h"
#import "StatusViewController.h"
#import "ChallengesViewController.h"
#import "LeaderboardViewController.h"
#import "UIFont+UrbanAdditions.h"
#import "ShopPageViewController.h"

@interface MenuViewController () {
    NSArray *tableArray;
}

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *shoppingArray = [NSArray arrayWithObjects:@"Womens", @"Mens", @"Apartment", @"Gift", @"Sale", nil];
    NSArray *appsArray = [NSArray arrayWithObjects:@"Music Player", @"Store Locator", @"Check-In", @"QR Scanner", nil];
    NSArray *loyaltyArray = [NSArray arrayWithObjects:@"MYUO Status", @"MYUO Profile", @"MYUO ID", @"UOChallengesU", @"UOLeaders", nil];
    
    tableArray = [NSArray arrayWithObjects:shoppingArray, appsArray, loyaltyArray, nil];
    
    UITableView *menu = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height)];
    menu.dataSource = self;
    menu.delegate = self;
    menu.rowHeight = 34.0;
    menu.backgroundColor = [UIColor offWhite];
    [menu setSeparatorColor:[UIColor blackColor]];
    [menu setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.view addSubview:menu];
    
    [menu setAllowsSelection:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [tableArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[tableArray objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ( section == 0 ) return @"Shop";
    else if ( section == 1 ) return @"Apps";
    else return @"UOANDU";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 24.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 0.0, tableView.bounds.size.width - 10.0, 0.0)];
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    label.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:17.0];
    label.shadowOffset = CGSizeMake(0, 1);
    label.shadowColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    [label sizeToFit];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(-10.0, 0.0, tableView.bounds.size.width, 24.0)];
    headerView.backgroundColor = [UIColor lightGrayColor];
    tableView.sectionHeaderHeight = headerView.frame.size.height;
    [headerView addSubview:label];

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, headerView.frame.size.width, 1.0)];
    line.backgroundColor = [UIColor blackColor];
    [headerView addSubview:line];
    
    line = [[UIView alloc] initWithFrame:CGRectMake(0.0, headerView.frame.size.height - 1.0, headerView.frame.size.width, 1.0)];
    line.backgroundColor = [UIColor blackColor];
    [headerView addSubview:line];
    
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 3;
}

//tableView:indentationLevelForRowAtIndexPath

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
    UIImageView *icon = nil;
    
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        
        UIView *selView = [[UIView alloc] initWithFrame:cell.frame];
        selView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
        cell.selectedBackgroundView = selView;
        
        icon = [[UIImageView alloc] initWithFrame:CGRectMake(8.0, 4.0, 24.0, 24.0)];
        icon.tag = 1;
        [[cell contentView] addSubview:icon];
        
        cell.textLabel.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:15.0];
        cell.textLabel.textColor = [UIColor blackColor];
    }

    NSString *text = [[tableArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    if ( !icon ) icon = (UIImageView *)[[cell contentView] viewWithTag:1];
    [icon setImage:nil];
    [icon setImage:[UIImage imageNamed:[text lowercaseString]]];
    
    cell.textLabel.text = text;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ViewController *revealController = [self.parentViewController isKindOfClass:[ViewController class]] ? (ViewController *)self.parentViewController : nil;
    
    NSString *selection = [[tableArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
//    NSArray *loyaltyArray = [NSArray arrayWithObjects:@"MYUO Status", @"MYUO Profile", @"MYUO ID", @"UOChallengesU", @"UOLeaders", nil];
    if ( indexPath.section == 0 ) {
        ShopPageViewController *shoppingVC = nil;
        if ( ![((UINavigationController *)revealController.frontViewController).topViewController isKindOfClass:[ShopPageViewController class]] ) {
            shoppingVC = [[ShopPageViewController alloc] init];
            shoppingVC.department = selection;
            [self loadNewFrontviewWithViewController:shoppingVC];
        }
        else {
            [revealController revealToggle:self];
            shoppingVC = (ShopPageViewController *)((UINavigationController *)revealController.frontViewController).topViewController;
            [shoppingVC updateViewWithTitle:selection];
        }
    }
    if ( [selection isEqualToString:@"MYUO Status"] ) {
        if ( ![((UINavigationController *)revealController.frontViewController).topViewController isKindOfClass:[StatusViewController class]] ) {
            StatusViewController *profileVC = [[StatusViewController alloc] init];
            [self loadNewFrontviewWithViewController:profileVC];
        }
        else [revealController revealToggle:self];
    }
    else if ( [selection isEqualToString:@"UOChallengesU"] ) {
        if ( ![((UINavigationController *)revealController.frontViewController).topViewController isKindOfClass:[ChallengesViewController class]] ) {
            ChallengesViewController *challengesVC = [[ChallengesViewController alloc] init];
            [self loadNewFrontviewWithViewController:challengesVC];
        }
        else [revealController revealToggle:self];
    }
    else if ( [selection isEqualToString:@"UOLeaders"] ) {
        if ( ![((UINavigationController *)revealController.frontViewController).topViewController isKindOfClass:[LeaderboardViewController class]] ) {
            LeaderboardViewController *leadersVC = [[LeaderboardViewController alloc] init];
            [self loadNewFrontviewWithViewController:leadersVC];
        }
        else [revealController revealToggle:self];
    }
    else {
        //[revealController revealToggle:self];
    }
}

- (void)loadNewFrontviewWithViewController:(UIViewController *)frontVC {
    ViewController *revealController = (ViewController *)self.parentViewController;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:frontVC];
    [revealController setFrontViewController:navigationController animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

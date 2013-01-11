//
//  MenuViewController.m
//  LoyaltyPrototype
//
//  Created by Jason Grandelli on 12/5/12.
//  Copyright (c) 2012 URBN. All rights reserved.
//

#import "MenuViewController.h"
#import "UIColor+ColorConstants.h"
#import "ViewController.h"
#import "ProfileViewController.h"
#import "ChallengesViewController.h"
#import "LeaderboardViewController.h"

@interface MenuViewController () {
    NSArray *tableArray;
}

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    tableArray = [NSArray arrayWithObjects:@"Profile", @"Challenges", @"Leaders", @"QR Scanner", @"Pictures", @"Alternate Reality", nil];
    
    UITableView *menu = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height)];
    menu.dataSource = self;
    menu.delegate = self;
    menu.rowHeight = 34.0;
    menu.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"menu_cell_bg"]];
    [menu setSeparatorColor:[UIColor lightNeonGreen]];
    [menu setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.view addSubview:menu];
    
    [menu setAllowsSelection:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tableArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        
        UIView *selView = [[UIView alloc] initWithFrame:cell.frame];
        selView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
        cell.selectedBackgroundView = selView;

        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        cell.textLabel.textColor = [UIColor offWhite];
    }

    cell.textLabel.text = [tableArray objectAtIndex:indexPath.row];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ViewController *revealController = [self.parentViewController isKindOfClass:[ViewController class]] ? (ViewController *)self.parentViewController : nil;
    
    NSString *selection = [tableArray objectAtIndex:indexPath.row];
    
    if ( [selection isEqualToString:@"Profile"] ) {
        if ( ![((UINavigationController *)revealController.frontViewController).topViewController isKindOfClass:[ProfileViewController class]] ) {
            ProfileViewController *profileVC = [[ProfileViewController alloc] init];
            [self loadNewFrontviewWithViewController:profileVC];
        }
        else [revealController revealToggle:self];
    }
    else if ( [selection isEqualToString:@"Challenges"] ) {
        if ( ![((UINavigationController *)revealController.frontViewController).topViewController isKindOfClass:[ChallengesViewController class]] ) {
            ChallengesViewController *challengesVC = [[ChallengesViewController alloc] init];
            [self loadNewFrontviewWithViewController:challengesVC];
        }
        else [revealController revealToggle:self];
    }
    else if ( [selection isEqualToString:@"Leaders"] ) {
        if ( ![((UINavigationController *)revealController.frontViewController).topViewController isKindOfClass:[LeaderboardViewController class]] ) {
            LeaderboardViewController *leadersVC = [[LeaderboardViewController alloc] init];
            [self loadNewFrontviewWithViewController:leadersVC];
        }
        else [revealController revealToggle:self];
    }
    else {
        [revealController revealToggle:self];
    }
}

- (void)loadNewFrontviewWithViewController:(UIViewController *)frontVC {
    ViewController *revealController = (ViewController *)self.parentViewController;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:frontVC];
    
    /*
    CGRect frame;

    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 2.0, self.view.bounds.size.width, 44.0)];
    nameLabel.textColor = [UIColor neonBlue];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.font = [UIFont boldSystemFontOfSize:16.0];
    nameLabel.text = @"Jason G.";
    frame = nameLabel.frame;
    [nameLabel sizeToFit];
    frame.size.height = nameLabel.frame.size.height;
    nameLabel.frame = frame;
    [navigationController.navigationBar addSubview:nameLabel];
    
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, frame.origin.y + frame.size.height + 3, self.view.bounds.size.width, 44.0)];
    statusLabel.textColor = [UIColor neonBlue];
    statusLabel.backgroundColor = [UIColor clearColor];
    statusLabel.textAlignment = NSTextAlignmentCenter;
    statusLabel.font = [UIFont boldSystemFontOfSize:12.0];
    statusLabel.text = @"Superior Being: 13500 pts";
    frame = statusLabel.frame;
    [statusLabel sizeToFit];
    frame.size.height = statusLabel.frame.size.height;
    statusLabel.frame = frame;
    [navigationController.navigationBar addSubview:statusLabel];
    */
    
    //[revealController revealToggle:self];
    [revealController setFrontViewController:navigationController animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

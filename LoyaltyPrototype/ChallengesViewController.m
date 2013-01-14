//
//  ChallengesViewController.m
//  LoyaltyPrototype
//
//  Created by Jason Grandelli on 12/12/12.
//  Copyright (c) 2012 URBN. All rights reserved.
//

#import "ChallengesViewController.h"
#import "UIColor+ColorConstants.h"
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import "ChallengeDetailViewController.h"
#import "NavBarItemsViewController.h"
#import "UserData.h"

@interface ChallengesViewController ()

@property (nonatomic, strong) UISegmentedControl *segmentedController;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *completedChallenges;
@property (nonatomic, strong) NSMutableArray *currentChallenges;
@property (nonatomic, strong) NSMutableArray *availableChallenges;
@property (nonatomic, weak) NSMutableArray *selectedArray;
@property (nonatomic, strong) NavBarItemsViewController *navBarItems;
@end

@implementation ChallengesViewController

#define TITLE_FONT_SIZE 16.0f
#define DESC_FONT_SIZE 12.0f
#define LEFT_MARGIN 45.0f
#define RIGHT_MARGIN 10.0f
#define VERT_MARGIN 9.0f

- (id)init {
	self = [super init];
	
	if (nil != self) {
        
	}
	
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.completedChallenges = [[NSMutableArray alloc] init];
    self.currentChallenges = [[NSMutableArray alloc] init];
    self.availableChallenges = [[NSMutableArray alloc] init];
    
    self.selectedArray = _currentChallenges;

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

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"🔁" style:UIBarButtonItemStylePlain target:self action:@selector(refreshData)];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                    [UIFont fontWithName:@"Entypo" size:45.0], UITextAttributeFont,
                                                                    [UIColor neonGreen], UITextAttributeTextColor, nil] forState:UIControlStateNormal];
    
    
    self.navBarItems = [[NavBarItemsViewController alloc] init];
    _navBarItems.view.frame = self.navigationController.navigationBar.bounds;
    [self.navigationController.navigationBar addSubview:_navBarItems.view];
    [_navBarItems updateInfo];
    
    self.segmentedController = [[UISegmentedControl alloc] initWithItems:@[@"Current", @"Available", @"Completed"]];
    _segmentedController.frame = CGRectMake( 15.0, self.navigationController.navigationBar.frame.size.height + 15.0, self.view.bounds.size.width - 30.0, 34.0);
    _segmentedController.segmentedControlStyle = UISegmentedControlStyleBar;
    _segmentedController.tintColor = [UIColor blackColor];
    [_segmentedController setBackgroundColor:[UIColor clearColor]];
    [_segmentedController setTitleTextAttributes:@{ UITextAttributeTextColor:[UIColor neonGreen] } forState:UIControlStateNormal];
    [_segmentedController setTitleTextAttributes:@{ UITextAttributeTextColor:[UIColor blackColor] } forState:UIControlStateSelected];
    [self.view addSubview:_segmentedController];
    
    [_segmentedController addTarget:self action:@selector(segmentedControlChanged:) forControlEvents:UIControlEventValueChanged];
    
    [_segmentedController setSelectedSegmentIndex:0];
    [self performSelector:@selector(segmentedControlChanged:) withObject:_segmentedController afterDelay:0.0];

    UIView *greenLine = [[UIView alloc] initWithFrame:CGRectMake(15.0,
                                                                 _segmentedController.frame.origin.y + _segmentedController.frame.size.height + 15.0,
                                                                 self.view.frame.size.width - 30.0, 1.0)];
    greenLine.backgroundColor = [UIColor neonGreen];
    greenLine.alpha = 0.3;
    [self.view addSubview:greenLine];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(15.0,
                                                                   greenLine.frame.origin.y + 1.0,
                                                                   self.view.frame.size.width - 30.0,
                                                                   self.view.frame.size.height - greenLine.frame.origin.y - 1.0)];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];

    [self getChallengeData];
}

- (void)refreshData {
    [self getChallengeData];
    NSURL *userURL = [NSURL URLWithString:[[UserData sharedInstance] userDataPath]];
    NSURLRequest *userReq = [NSURLRequest requestWithURL:userURL];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:userReq
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            JSON = [JSON objectForKey:@"Nitro"];
                                                                                            UserData *userData = [UserData sharedInstance];
                                                                                            [userData parseUserData:JSON];
                                                                                            [_navBarItems updateInfo];
                                                                                        }
                                                                                        failure:nil];
    [operation start];

}

- (void)getChallengeData {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *baseURL = @"https://sandbox.bunchball.net/nitro/json?method=user.getChallengeProgress&showonlytrophies=false&showCanAchieveChallenge=true&sessionKey=";
    NSString *path = [NSString stringWithFormat:@"%@%@", baseURL, [[UserData sharedInstance] sessionKey]];
    NSURL *url = [NSURL URLWithString:path];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:req
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            JSON = [JSON objectForKey:@"Nitro"];
                                                                                            JSON = [JSON objectForKey:@"challenges"];
                                                                                            JSON = [JSON objectForKey:@"Challenge"];
                                                                                            [self finishedLoadingWithData:JSON];
                                                                                        }
                                                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                            NSLog(@"%@", error);
                                                                                        }];
    [operation start];
}

- (void)finishedLoadingWithData:(NSDictionary *)JSON {
    [_currentChallenges removeAllObjects];
    [_completedChallenges removeAllObjects];
    [_availableChallenges removeAllObjects];
    
    for ( NSDictionary *dict in JSON ) {
        ChallengeData *challenge = [[ChallengeData alloc] initWithDictionary:dict];
        if ( challenge.completion == 0.0 ) [self.availableChallenges addObject:challenge];
        else if ( challenge.completion == 1.0 ) [self.completedChallenges addObject:challenge];
        else [self.currentChallenges addObject:challenge];
    }
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [_tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_selectedArray count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChallengeData *challenge = [_selectedArray objectAtIndex:[indexPath row]];
    
    NSString *title = [NSString stringWithFormat:@"%@: %@ points", challenge.title, challenge.pointsString];
    NSString *desc = challenge.description;
    int perc = challenge.completion * 100;
    NSString *complete = [NSString stringWithFormat:@"%i%% completed", perc];
    
    CGSize constraint = CGSizeMake(_tableView.frame.size.width - LEFT_MARGIN - RIGHT_MARGIN, 2000.0);
    CGSize titleSize = [title sizeWithFont:[UIFont systemFontOfSize:TITLE_FONT_SIZE] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    CGSize completeSize = [complete sizeWithFont:[UIFont systemFontOfSize:TITLE_FONT_SIZE] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    CGSize descSize = [desc sizeWithFont:[UIFont systemFontOfSize:DESC_FONT_SIZE] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat height;
    if ( _segmentedController.selectedSegmentIndex != 0 ) height = titleSize.height + descSize.height + (VERT_MARGIN * 2);
    else height = titleSize.height + completeSize.height + descSize.height + (VERT_MARGIN * 2);
    
    return MAX(height, 54.0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
    UILabel *titleLabel = nil;
    UILabel *percentLable = nil;
    UILabel *descriptionLabel = nil;
    UILabel *iconLabel = nil;
    
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        
        UIView *selView = [[UIView alloc] initWithFrame:cell.frame];
        selView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
        cell.selectedBackgroundView = selView;
        cell.backgroundColor = [UIColor blueColor];
        
        iconLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, -6.0, 40.0, 100.0)];
        iconLabel.textColor = [UIColor neonGreen];
        iconLabel.backgroundColor = [UIColor clearColor];
        iconLabel.tag = 1;
        [cell addSubview:iconLabel];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_MARGIN, VERT_MARGIN, _tableView.frame.size.width - LEFT_MARGIN - RIGHT_MARGIN, 1000.0)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor offWhite];
        titleLabel.font = [UIFont systemFontOfSize:16.0];
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.numberOfLines = 0;
        titleLabel.tag = 2;
        [[cell contentView] addSubview:titleLabel];
        
        percentLable = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_MARGIN, VERT_MARGIN, _tableView.frame.size.width - LEFT_MARGIN - RIGHT_MARGIN, 1000.0)];
        percentLable.backgroundColor = [UIColor clearColor];
        percentLable.textColor = [UIColor neonBlue];
        percentLable.font = [UIFont systemFontOfSize:16.0];
        percentLable.lineBreakMode = NSLineBreakByWordWrapping;
        percentLable.numberOfLines = 0;
        percentLable.tag = 3;
        [[cell contentView] addSubview:percentLable];
        
        descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_MARGIN, VERT_MARGIN, _tableView.frame.size.width - LEFT_MARGIN - RIGHT_MARGIN, 1000.0)];
        descriptionLabel.backgroundColor = [UIColor clearColor];
        descriptionLabel.textColor = [UIColor offWhite];
        descriptionLabel.font = [UIFont systemFontOfSize:12.0];
        descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        descriptionLabel.numberOfLines = 0;
        descriptionLabel.tag = 4;
        [[cell contentView] addSubview:descriptionLabel];
    }
    
    ChallengeData *challenge = [_selectedArray objectAtIndex:[indexPath row]];
    
    if ( !iconLabel ) iconLabel = (UILabel *)[cell viewWithTag:1];
    iconLabel.font = [UIFont fontWithName:challenge.iconFont size:62.0];
    iconLabel.text = challenge.icon;
    [iconLabel sizeToFit];
    
    NSString *title = [NSString stringWithFormat:@"%@: %@ points", challenge.title, challenge.pointsString];
    if ( !titleLabel ) titleLabel = (UILabel *)[cell viewWithTag:2];
    titleLabel.frame = CGRectMake(LEFT_MARGIN, VERT_MARGIN, _tableView.frame.size.width - LEFT_MARGIN - RIGHT_MARGIN, 1000.0);
    titleLabel.text = title;
    if ( _segmentedController.selectedSegmentIndex == 2 ) titleLabel.textColor = [UIColor neonBlue];
    else titleLabel.textColor = [UIColor offWhite];
    [titleLabel sizeToFit];
    
    int yPos = roundf(titleLabel.frame.size.height + titleLabel.frame.origin.y);
    
    if ( !percentLable ) percentLable = (UILabel *)[cell viewWithTag:3];
    if ( _segmentedController.selectedSegmentIndex != 0 ) percentLable.text = @"";
    else {
        percentLable.frame = CGRectMake(LEFT_MARGIN, yPos, _tableView.frame.size.width - LEFT_MARGIN - RIGHT_MARGIN, 1000.0);
        int perc = challenge.completion * 100;
        percentLable.text = [NSString stringWithFormat:@"%i%% completed", perc];
        [percentLable sizeToFit];
        yPos = roundf(percentLable.frame.size.height + percentLable.frame.origin.y);
    }
    
    if ( !descriptionLabel ) descriptionLabel = (UILabel *)[cell viewWithTag:4];
    descriptionLabel.frame = CGRectMake(LEFT_MARGIN, yPos, _tableView.frame.size.width - LEFT_MARGIN - RIGHT_MARGIN, 1000.0);
    descriptionLabel.text = challenge.description;
    [descriptionLabel sizeToFit];

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ChallengeData *data = [_selectedArray objectAtIndex:indexPath.row];
    ChallengeDetailViewController *detailView = [[ChallengeDetailViewController alloc] initWithData:data];
    [self.navigationController pushViewController:detailView animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)segmentedControlChanged:(UISegmentedControl *)sender {
    for (int i = 0; i < [sender.subviews count]; i++) {
        if ([[sender.subviews objectAtIndex:i]isSelected] ) {
            UIColor *tintcolor = [UIColor neonGreen];
            [[sender.subviews objectAtIndex:i] setTintColor:tintcolor];
        }
        else [[sender.subviews objectAtIndex:i] setTintColor:[UIColor blackColor]];
    }
    
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.selectedArray = _currentChallenges;
            break;
        case 1:
            self.selectedArray = _availableChallenges;
            break;
        case 2:
            self.selectedArray = _completedChallenges;
            break;
    }
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

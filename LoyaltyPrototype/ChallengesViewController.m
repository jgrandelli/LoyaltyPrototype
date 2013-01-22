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
#import "BackgroundView.h"
#import "UIFont+UrbanAdditions.h"

@interface ChallengesViewController ()

@property (nonatomic, strong) UISegmentedControl *segmentedController;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *completedChallenges;
@property (nonatomic, strong) NSMutableArray *currentChallenges;
@property (nonatomic, strong) NSMutableArray *availableChallenges;
@property (nonatomic, weak) NSMutableArray *selectedArray;
@property (nonatomic, strong) NavBarItemsViewController *navBarItems;
@property (nonatomic) int currentSelection;

@end

@implementation ChallengesViewController

#define TITLE_FONT_SIZE 16.0f
#define DESC_FONT_SIZE 12.0f
#define LEFT_MARGIN 48.0f
#define RIGHT_MARGIN 18.0f
#define VERT_MARGIN 10.0f

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

    int i = (arc4random() % 9) + 1;
    NSString *patternName = [NSString stringWithFormat:@"Background%i", i];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:patternName]];

    self.navBarItems = [[NavBarItemsViewController alloc] init];
    _navBarItems.pageName = @"UOChallengesU";
    [_navBarItems.view setFrame:self.navigationController.navigationBar.bounds];
    [_navBarItems updateInfo];
    [self.navigationController.navigationBar addSubview:_navBarItems.view];
    
    if ([self.navigationController.parentViewController respondsToSelector:@selector(revealGesture:)] &&
        [self.navigationController.parentViewController respondsToSelector:@selector(revealToggle:)])
    {
        UIPanGestureRecognizer *navigationBarPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self.navigationController.parentViewController action:@selector(revealGesture:)];
		[self.navigationController.navigationBar addGestureRecognizer:navigationBarPanGestureRecognizer];
	}
    
    BackgroundView *backView = [[BackgroundView alloc] initWithFrame:CGRectMake(15.0, self.navigationController.navigationBar.frame.size.height + 15.0, self.view.bounds.size.width - 30.0, 44.0)];
    [self.view addSubview:backView];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.frame = CGRectMake(backView.frame.origin.x + 3.0, backView.frame.origin.y + 3.0, 93.0, 34.0);
    [btn1 setImage:[UIImage imageNamed:@"currentBtn"] forState:UIControlStateNormal];
    [btn1 setImage:[UIImage imageNamed:@"currentBtn-selected"] forState:UIControlStateSelected];
    btn1.tag = 100;
    [btn1 addTarget:self action:@selector(segmentedBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    [self performSelector:@selector(segmentedBtnPressed:) withObject:[self.view viewWithTag:100]];
    
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(btn1.frame.origin.x + btn1.frame.size.width, btn1.frame.origin.y, 93.0, 34);
    [btn2 setImage:[UIImage imageNamed:@"availableBtn"] forState:UIControlStateNormal];
    [btn2 setImage:[UIImage imageNamed:@"availableBtn-selected"] forState:UIControlStateSelected];
    btn2.tag = 101;
    [btn2 addTarget:self action:@selector(segmentedBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];

    UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn3.frame = CGRectMake(btn2.frame.origin.x + btn2.frame.size.width, btn1.frame.origin.y, 93.0, 34);
    [btn3 setImage:[UIImage imageNamed:@"completedBtn"] forState:UIControlStateNormal];
    [btn3 setImage:[UIImage imageNamed:@"completedBtn-selected"] forState:UIControlStateSelected];
    btn3.tag = 102;
    [btn3 addTarget:self action:@selector(segmentedBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn3];
    
    UIView *blackBar = [[UIView alloc] initWithFrame:CGRectMake(btn2.frame.origin.x - 1, btn2.frame.origin.y - 1.0, 2.0, btn2.frame.size.height + 2.0)];
    blackBar.backgroundColor = [UIColor blackColor];
    [self.view addSubview:blackBar];

    blackBar = [[UIView alloc] initWithFrame:CGRectMake(btn3.frame.origin.x - 1, btn3.frame.origin.y - 1.0, 2.0, btn3.frame.size.height + 2.0)];
    blackBar.backgroundColor = [UIColor blackColor];
    [self.view addSubview:blackBar];
    
    
    UIView *blackDivider = [[UIView alloc] initWithFrame:CGRectMake(15.0,
                                                                    backView.frame.origin.y + backView.frame.size.height + 10.0,
                                                                    self.view.frame.size.width - 30.0, 3.0)];
    blackDivider.backgroundColor = [UIColor blackColor];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(15.0,
                                                                   blackDivider.frame.origin.y + 1.0,
                                                                   self.view.frame.size.width - 30.0,
                                                                   self.view.frame.size.height - blackDivider.frame.origin.y - 1.0)];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];

    [self.view addSubview:blackDivider];

    [self getChallengeData];
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
    
    UIImage *rightImg = [UIImage imageNamed:@"refreshBtn"];
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(self.view.frame.size.width - rightImg.size.width - 10.0, 5.0, rightImg.size.width, rightImg.size.height);
    [rightBtn setImage:rightImg forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.tag = 2;
    [self.navigationController.navigationBar addSubview:rightBtn];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    UIButton *btn = (UIButton *)[self.navigationController.navigationBar viewWithTag:1];
    [btn removeFromSuperview];
    
    btn = (UIButton *)[self.navigationController.navigationBar viewWithTag:2];
    [btn removeFromSuperview];
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
    NSString *complete = [NSString stringWithFormat:@" (%i%% completed)", perc];
    if ( _currentSelection == 0 ) title = [title stringByAppendingString:complete];
    
    CGSize constraint = CGSizeMake(_tableView.frame.size.width - LEFT_MARGIN - RIGHT_MARGIN, 2000.0);
    CGSize titleSize = [title sizeWithFont:[UIFont fontNamedLoRes12BoldOaklandWithSize:15.0] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    CGSize descSize = [desc sizeWithFont:[UIFont fontNamedLoRes15BoldOaklandWithSize:14.0] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat height;
    height = titleSize.height + descSize.height + 2.0 + (VERT_MARGIN * 2) + 20.0;
    
    return MAX(height, 54.0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
    BackgroundView *backView = nil;
    UILabel *titleLabel = nil;
    UILabel *descriptionLabel = nil;
    UIImageView *icon = nil;
    
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        
        UIView *selView = [[UIView alloc] initWithFrame:cell.frame];
        selView.backgroundColor = [UIColor clearColor];
        cell.selectedBackgroundView = selView;
        
        backView = [[BackgroundView alloc] initWithFrame:CGRectMake(0.0, 10.0, self.view.bounds.size.width - 30.0, 0.0)];
        backView.tag = 1;
        [[cell contentView]  addSubview:backView];
        
        icon = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, backView.frame.origin.y + VERT_MARGIN, 28.0, 28.0)];
        icon.tag = 2;
        [[cell contentView] addSubview:icon];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_MARGIN, icon.frame.origin.y, backView.frame.size.width - LEFT_MARGIN - RIGHT_MARGIN, 0.0)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:15.0];
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.numberOfLines = 0;
        titleLabel.tag = 3;
        [[cell contentView] addSubview:titleLabel];

        descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x, icon.frame.origin.y, backView.frame.size.width - LEFT_MARGIN - RIGHT_MARGIN, 0.0)];
        descriptionLabel.backgroundColor = [UIColor clearColor];
        descriptionLabel.textColor = [UIColor blackColor];
        descriptionLabel.font = [UIFont fontNamedLoRes15BoldOaklandWithSize:14.0];
        descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        descriptionLabel.numberOfLines = 0;
        descriptionLabel.tag = 4;
        [[cell contentView] addSubview:descriptionLabel];
    }
    
    ChallengeData *challenge = [_selectedArray objectAtIndex:[indexPath row]];
    
    if ( !backView ) backView = (BackgroundView *)[cell viewWithTag:1];

    if ( !icon ) icon = (UIImageView *)[cell viewWithTag:2];
    [icon setImage:nil];
    UIImage *img = [UIImage imageNamed:challenge.icon];
    [icon setImage:img];
    
    NSString *title = [NSString stringWithFormat:@"%@: %@ points", challenge.title, challenge.pointsString];
    NSString *pointsText = [NSString stringWithFormat:@"%@ points", challenge.pointsString];
    int perc = challenge.completion * 100;
    NSString *percentText = [NSString stringWithFormat:@" (%i%% completed)", perc];
    
    if ( _currentSelection == 0 ) title = [title stringByAppendingString:percentText];
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:title];
    NSRange pointsRange = [title rangeOfString:pointsText];
    UIColor *pointsColor = [UIColor blueColor];

    NSRange percRange = [title rangeOfString:percentText];
    UIColor *percColor = [UIColor redColor];

    [attString addAttribute:NSForegroundColorAttributeName value:pointsColor range:pointsRange];
    if ( _currentSelection == 0 ) [attString addAttribute:NSForegroundColorAttributeName value:percColor range:percRange];
    
    if ( !titleLabel ) titleLabel = (UILabel *)[cell viewWithTag:3];
    titleLabel.frame = CGRectMake(LEFT_MARGIN, backView.frame.origin.y + VERT_MARGIN, backView.frame.size.width - LEFT_MARGIN - RIGHT_MARGIN, 0.0);
    titleLabel.attributedText = attString;
    [titleLabel sizeToFit];

    int yPos = roundf(titleLabel.frame.size.height + titleLabel.frame.origin.y) + 2.0;
    
    if ( !descriptionLabel ) descriptionLabel = (UILabel *)[cell viewWithTag:4];
    descriptionLabel.frame = CGRectMake(titleLabel.frame.origin.x, yPos, backView.frame.size.width - LEFT_MARGIN - RIGHT_MARGIN, 0.0);
    descriptionLabel.text = challenge.description;
    [descriptionLabel sizeToFit];

    CGRect frame = backView.frame;
    frame.size.height = descriptionLabel.frame.origin.y + descriptionLabel.frame.size.height + VERT_MARGIN;
    backView.frame = frame;
    [backView setNeedsDisplay];
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ChallengeData *data = [_selectedArray objectAtIndex:indexPath.row];
    ChallengeDetailViewController *detailView = [[ChallengeDetailViewController alloc] initWithData:data];
    [self.navigationController pushViewController:detailView animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)segmentedBtnPressed:(id)sender {
    for (int i = 100; i < 103; ++i) {
        UIButton *btn = (UIButton *)[self.view viewWithTag:i];
        if ( i == [sender tag] ) btn.selected = YES;
        else btn.selected = NO;
    }
    
    switch ([sender tag]) {
        case 100:
            self.selectedArray = _currentChallenges;
            self.currentSelection = 0;
            break;
        case 101:
            self.selectedArray = _availableChallenges;
            self.currentSelection = 1;
            break;
        case 102:
            self.selectedArray = _completedChallenges;
            self.currentSelection = 2;
            break;
    }
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

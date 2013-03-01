//
//  FriendsViewController.m
//  LoyaltyPrototype
//
//  Created by Jason Grandelli on 2/13/13.
//  Copyright (c) 2013 URBN. All rights reserved.
//

#import "FriendsViewController.h"
#import "BackgroundView.h"
#import "UIFont+UrbanAdditions.h"
#import "NavBarItemsViewController.h"
#import <AFNetworking.h>
#import <MBProgressHUD.h>
#import "UserData.h"
#import <QuartzCore/QuartzCore.h>
#import "PendingFriendsViewController.h"
#import "FindFriendsViewController.h"

#import <Parse/Parse.h>

@interface FriendsViewController ()

@property (nonatomic, strong) NavBarItemsViewController *navBarItems;
@property (nonatomic, strong) UIButton *requestsBTN;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *tableData;
@property (nonatomic) int pendingCount;
@property (nonatomic, strong) UIView *pendingAlertView;

@end

@implementation FriendsViewController

#define MARGIN 15.0f
#define PADDING 10.0f
#define IMAGE_SIZE 35.0f
#define FRIEND_LIST_PATH @"http://sandbox.bunchball.net/nitro/json?method=user.getFriends&userId=16&friendType="
#define USER_PREF_PATH @"http://sandbox.bunchball.net/nitro/json?method=user.getPreferences"
#define DELETE_FRIEND_PATH @"http://sandbox.bunchball.net/nitro/json?method=user.removeFriend&userId=16"

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    int i = (arc4random() % 4) + 1;
    NSString *patternName = [NSString stringWithFormat:@"Background%i", i];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:patternName]];
    
    self.navBarItems = [[NavBarItemsViewController alloc] init];
    _navBarItems.pageName = @"Friends";
    [_navBarItems.view setFrame:self.navigationController.navigationBar.bounds];
    [self.navigationController.navigationBar addSubview:_navBarItems.view];
    
    if ([self.navigationController.parentViewController respondsToSelector:@selector(revealGesture:)] &&
        [self.navigationController.parentViewController respondsToSelector:@selector(revealToggle:)])
    {
        UIPanGestureRecognizer *navigationBarPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self.navigationController.parentViewController action:@selector(revealGesture:)];
		[self.navigationController.navigationBar addGestureRecognizer:navigationBarPanGestureRecognizer];
	}
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, 75.0)];
    backView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:backView];
    
    UILabel *requestsLbl = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 0.0, 0.0)];
    requestsLbl.backgroundColor = [UIColor clearColor];
    requestsLbl.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:14.0];
    requestsLbl.text = @"Requests";
    [requestsLbl sizeToFit];

    UIImage *btnImg = [UIImage imageNamed:@"stretchableRoundedBtn"];
    UIEdgeInsets insets = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0);
    btnImg = [btnImg resizableImageWithCapInsets:insets];

    self.requestsBTN = [UIButton buttonWithType:UIButtonTypeCustom];
    _requestsBTN.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    _requestsBTN.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    _requestsBTN.frame = CGRectMake(PADDING, PADDING + 5.0, 140.0, 40.0);
    [_requestsBTN setImage:btnImg forState:UIControlStateNormal];
    [_requestsBTN addTarget:self action:@selector(requestBtnTouched) forControlEvents:UIControlEventTouchUpInside];
    [_requestsBTN addSubview:requestsLbl];
    
    CGRect frame = requestsLbl.frame;
    frame.origin.x = _requestsBTN.frame.size.width*.5 - frame.size.width*0.5;
    frame.origin.y = _requestsBTN.frame.size.height*.5 - frame.size.height*0.5;
    requestsLbl.frame = frame;
    
    [backView addSubview:_requestsBTN];
    
    UILabel *findLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    findLbl.backgroundColor = [UIColor clearColor];
    findLbl.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:14.0];
    findLbl.text = @"Find Friends";
    [findLbl sizeToFit];
    
    UIButton *findBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    findBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    findBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    findBtn.frame = CGRectMake(_requestsBTN.frame.origin.x + _requestsBTN.frame.size.width + 20.0, PADDING + 5.0, 140.0, 40.0);
    [findBtn setImage:btnImg forState:UIControlStateNormal];
    [findBtn addTarget:self action:@selector(findFriendsTouched) forControlEvents:UIControlEventTouchUpInside];
    [findBtn addSubview:findLbl];
    
    frame = findLbl.frame;
    frame.origin.x = findBtn.frame.size.width*.5 - frame.size.width*0.5;
    frame.origin.y = findBtn.frame.size.height*.5 - frame.size.height*0.5;
    findLbl.frame = frame;
    
    [backView addSubview:findBtn];
    
    self.tableData = [[NSMutableArray alloc] init];
    
    UIView *blackLine = [[UIView alloc] initWithFrame:CGRectMake(0.0, backView.frame.origin.y + backView.frame.size.height - 3.0, self.view.frame.size.width, 3.0)];
    blackLine.backgroundColor = [UIColor blackColor];
    [self.view addSubview:blackLine];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, blackLine.frame.origin.y + 3.0, self.view.frame.size.width, self.view.frame.size.height - blackLine.frame.origin.y - 3.0)];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.allowsSelection = NO;
    [self.view addSubview:_tableView];
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
    [rightBtn addTarget:self action:@selector(getFriendData) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.tag = 2;
    [self.navigationController.navigationBar addSubview:rightBtn];
    
    [self getFriendData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    UIButton *btn = (UIButton *)[self.navigationController.navigationBar viewWithTag:1];
    [btn removeFromSuperview];
    
    btn = (UIButton *)[self.navigationController.navigationBar viewWithTag:2];
    [btn removeFromSuperview];
}

- (void)refreshData {
    [self getFriendData];
}

- (void)getFriendData {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *friendPath = [NSString stringWithFormat:@"%@current&sessionKey=%@", FRIEND_LIST_PATH, [[UserData sharedInstance] sessionKey]];
    NSURL *friendURL = [NSURL URLWithString:friendPath];
    NSURLRequest *friendReq = [NSURLRequest requestWithURL:friendURL];
    AFJSONRequestOperation *friendOp = [AFJSONRequestOperation JSONRequestOperationWithRequest:friendReq
                                                                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                           JSON = [[JSON objectForKey:@"Nitro"] objectForKey:@"users"];
                                                                                           [self finishedLoadingFriends:JSON];
                                                                                       }
                                                                                       failure:nil];
    [friendOp start];
    
    NSString *requestsPath = [NSString stringWithFormat:@"%@incoming&sessionKey=%@", FRIEND_LIST_PATH, [[UserData sharedInstance] sessionKey]];
    NSURL *requestsURL = [NSURL URLWithString:requestsPath];
    NSURLRequest *requestsReq = [NSURLRequest requestWithURL:requestsURL];
    AFJSONRequestOperation *requestsOp = [AFJSONRequestOperation JSONRequestOperationWithRequest:requestsReq
                                                                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                             JSON = [[JSON objectForKey:@"Nitro"] objectForKey:@"users"];
                                                                                             [self updatePendingCount:JSON];
                                                                                         }
                                                                                         failure:nil];
    [requestsOp start];
}

- (void)finishedLoadingFriends:(NSDictionary *)JSON {
    [_tableData removeAllObjects];
    
    NSMutableArray *opArray = [[NSMutableArray alloc] init];
    for ( NSDictionary *user in [JSON objectForKey:@"User"] ) {
        NSString *userPath = [NSString stringWithFormat:@"%@&userId=%@&sessionKey=%@", USER_PREF_PATH, [user objectForKey:@"userId"], [[UserData sharedInstance] sessionKey]];
        NSURL *userURL = [NSURL URLWithString:userPath];
        NSURLRequest *userReq = [NSURLRequest requestWithURL:userURL];
        AFJSONRequestOperation *userOp = [AFJSONRequestOperation JSONRequestOperationWithRequest:userReq
                                                                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                             JSON = [[JSON objectForKey:@"Nitro"] objectForKey:@"userPreferences"];
                                                                                             [self parseUserData:JSON userID:[user objectForKey:@"userId"]];
                                                                                           }
                                                                                         failure:nil];
        
        [opArray addObject:userOp];
    }

    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@""]];
    [client enqueueBatchOfHTTPRequestOperations:opArray
                                  progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
                                      nil;
                                  }
                                completionBlock:^(NSArray *operations) {
                                    [self finishedUserBatch];
                                }];

}

- (void)parseUserData:(NSDictionary *)JSON userID:(NSString *)userID {
    NSString *handle = @"";
    NSString *imgPath = @"";
    
    for ( NSDictionary *pref in [JSON objectForKey:@"UserPreference"] ) {
        if ( [[pref objectForKey:@"name"] isEqualToString:@"profile_name"] ) handle = [pref objectForKey:@"value"];
        else if ( [[pref objectForKey:@"name"] isEqualToString:@"profile_url"] ) imgPath = [pref objectForKey:@"value"];
    }

    NSDictionary *userDict = @{ @"userID":userID, @"handle":handle, @"imgPath":imgPath };
    
    [_tableData addObject:userDict];
}

- (void)finishedUserBatch {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [_tableView reloadData];
}

#pragma mark - UITableViewDelegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return IMAGE_SIZE + PADDING*2;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *user = [_tableData objectAtIndex:indexPath.row];
    
    NSString *friendPath = [NSString stringWithFormat:@"%@&friendId=%@&sessionKey=%@", DELETE_FRIEND_PATH, [user objectForKey:@"userID"], [[UserData sharedInstance] sessionKey]];
    NSURL *friendURL = [NSURL URLWithString:friendPath];
    NSURLRequest *friendReq = [NSURLRequest requestWithURL:friendURL];
    AFJSONRequestOperation *friendOp = [AFJSONRequestOperation JSONRequestOperationWithRequest:friendReq
                                                                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                           
                                                                                       }
                                                                                       failure:nil];
    [friendOp start];
    [_tableData removeObjectAtIndex:indexPath.row];
    [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
    UIImageView *profileImageView = nil;
    UILabel *handleLabel = nil;
    
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        
        UIView *selView = [[UIView alloc] initWithFrame:cell.frame];
        selView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
        cell.selectedBackgroundView = selView;
        
        profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING, PADDING, IMAGE_SIZE, IMAGE_SIZE)];
        profileImageView.layer.borderWidth = 2;
        profileImageView.layer.borderColor = [UIColor blackColor].CGColor;
        profileImageView.tag = 1;
        
        [[cell contentView] addSubview:profileImageView];
        
        handleLabel = [[UILabel alloc] initWithFrame:CGRectMake(profileImageView.frame.origin.x + profileImageView.frame.size.width + 15.0,
                                                                profileImageView.frame.origin.y + 8.0,
                                                                0.0,
                                                                0.0)];
        
        handleLabel.backgroundColor = [UIColor clearColor];
        handleLabel.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:18.0];
        handleLabel.textColor = [UIColor blackColor];
        handleLabel.tag = 2;
        [[cell contentView] addSubview:handleLabel];
    }
    
    NSDictionary *userDict = [_tableData objectAtIndex:indexPath.row];
    
    if ( !profileImageView ) profileImageView = (UIImageView *)[cell viewWithTag:1];
    [profileImageView setImageWithURL:[NSURL URLWithString:[userDict objectForKey:@"imgPath"]] placeholderImage:[UIImage imageNamed:@"profileHolderImg"]];
    
    if ( !handleLabel ) handleLabel = (UILabel *)[cell viewWithTag:2];
    handleLabel.text = [[userDict objectForKey:@"handle"] uppercaseString];
    [handleLabel sizeToFit];
    
	return cell;
}

- (void)updatePendingCount:(NSDictionary *)JSON {
    NSArray *arr = [JSON objectForKey:@"User"];
    self.pendingCount = [arr count];
    
    if ( _pendingCount > 0 ) {
        UILabel *countLabel;
        if ( !_pendingAlertView ) {
            _pendingAlertView = [[UIView alloc] initWithFrame:CGRectMake(_requestsBTN.frame.size.width - 15.0, -5.0, 20.0, 20.0)];
            _pendingAlertView.backgroundColor = [UIColor clearColor];
            UIImageView *alertImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"alertIcon"]];
            alertImg.frame = CGRectMake(0.0, 0.0, 20.0, 20.0);
            [_pendingAlertView addSubview:alertImg];
            
            countLabel = [[UILabel alloc] initWithFrame:CGRectMake(2.0, 2.0, 0.0, 0.0)];
            countLabel.backgroundColor = [UIColor clearColor];
            countLabel.textColor = [UIColor whiteColor];
            countLabel.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:12.0];
            [_pendingAlertView addSubview:countLabel];
            
            _pendingAlertView.userInteractionEnabled = NO;
        }
        else {
            countLabel = (UILabel *)[_pendingAlertView.subviews objectAtIndex:1];
        }
        
        countLabel.text = [NSString stringWithFormat:@"%i", _pendingCount];
        [countLabel sizeToFit];
        
        CGRect frame = countLabel.frame;
        frame.origin.x = _pendingAlertView.frame.size.width*.5 - frame.size.width*.5;
        frame.origin.y = _pendingAlertView.frame.size.height*.5 - frame.size.height*.5;
        countLabel.frame = frame;
        
        [_requestsBTN addSubview:_pendingAlertView];
    }
    else {
    
    }
}

- (void)requestBtnTouched {
    PendingFriendsViewController *pendingVC = [[PendingFriendsViewController alloc] init];
    [self.navigationController pushViewController:pendingVC animated:YES];
}

- (void)findFriendsTouched {
    FindFriendsViewController *findVC = [[FindFriendsViewController alloc] init];
    [self.navigationController pushViewController:findVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

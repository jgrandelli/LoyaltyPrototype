//
//  PendingFriendsViewController.m
//  LoyaltyPrototype
//
//  Created by Jason Grandelli on 2/15/13.
//  Copyright (c) 2013 URBN. All rights reserved.
//

#import "PendingFriendsViewController.h"
#import "NavBarItemsViewController.h"
#import "UserData.h"
#import "UIFont+UrbanAdditions.h"
#import <AFNetworking.h>
#import <MBProgressHUD.h>
#import <QuartzCore/QuartzCore.h>

@interface PendingFriendsViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *tableData;

@end

@implementation PendingFriendsViewController

#define PADDING 10.0f
#define IMAGE_SIZE 35.0f
#define BASE_PATH @"http://sandbox.bunchball.net/nitro/json?"
#define FRIEND_LIST_PATH @"method=user.getFriends&userId=16&friendType="
#define USER_PREF_PATH @"method=user.getPreferences"
#define ACCEPT_FRIEND_PATH @"method=user.acceptFriend&userId=16"
#define DENY_FRIEND_PATH @"method=user.removeFriend&userId=16"


- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    int i = (arc4random() % 4) + 1;
    NSString *patternName = [NSString stringWithFormat:@"Background%i", i];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:patternName]];
    
    [self.navigationItem setHidesBackButton:YES];
    
    if ([self.navigationController.parentViewController respondsToSelector:@selector(revealGesture:)] &&
        [self.navigationController.parentViewController respondsToSelector:@selector(revealToggle:)])
    {
        UIPanGestureRecognizer *navigationBarPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self.navigationController.parentViewController action:@selector(revealGesture:)];
		[self.navigationController.navigationBar addGestureRecognizer:navigationBarPanGestureRecognizer];
	}
    
    self.tableData = [[NSMutableArray alloc] init];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height -self.navigationController.navigationBar.frame.size.height)];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.allowsSelection = NO;
    [self.view addSubview:_tableView];    
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

- (void)backBtnPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getFriendData {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *requestsPath = [NSString stringWithFormat:@"%@%@incoming&sessionKey=%@", BASE_PATH, FRIEND_LIST_PATH, [[UserData sharedInstance] sessionKey]];
    NSURL *requestsURL = [NSURL URLWithString:requestsPath];
    NSURLRequest *requestsReq = [NSURLRequest requestWithURL:requestsURL];
    AFJSONRequestOperation *requestsOp = [AFJSONRequestOperation JSONRequestOperationWithRequest:requestsReq
                                                                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                             JSON = [[JSON objectForKey:@"Nitro"] objectForKey:@"users"];
                                                                                             [self finishedLoadingFriends:JSON];
                                                                                         }
                                                                                         failure:nil];
    [requestsOp start];
}

- (void)finishedLoadingFriends:(NSDictionary *)JSON {
    [_tableData removeAllObjects];
    NSMutableArray *opArray = [[NSMutableArray alloc] init];
    for ( NSDictionary *user in [JSON objectForKey:@"User"] ) {
        NSString *userPath = [NSString stringWithFormat:@"%@%@&userId=%@&sessionKey=%@", BASE_PATH, USER_PREF_PATH, [user objectForKey:@"userId"], [[UserData sharedInstance] sessionKey]];
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
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeContactAdd];
        cell.accessoryView = btn;
        [btn addTarget:self action:@selector(requestFriend:event:) forControlEvents:UIControlEventTouchUpInside];
        
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *userDict = [_tableData objectAtIndex:indexPath.row];
    
    NSString *requestPath = [NSString stringWithFormat:@"%@%@&friendId=%@&sessionKey=%@", BASE_PATH, DENY_FRIEND_PATH, [userDict objectForKey:@"userID"], [[UserData sharedInstance] sessionKey]];
    NSURL *requestURL = [NSURL URLWithString:requestPath];
    NSURLRequest *requestReq = [NSURLRequest requestWithURL:requestURL];
    
    AFJSONRequestOperation *requestOp = [AFJSONRequestOperation JSONRequestOperationWithRequest:requestReq
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            //JSON = [[JSON objectForKey:@"Nitro"] objectForKey:@"users"];
                                                                                            //[self finishedLoadingFriends:JSON];
                                                                                        }
                                                                                        failure:nil];
    [requestOp start];

    [_tableData removeObjectAtIndex:indexPath.row];
    [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)requestFriend:(id)sender event:(id)event {
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:currentTouchPosition];
    if (indexPath != nil){
        //[self tableView:_tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
        NSDictionary *userDict = [_tableData objectAtIndex:indexPath.row];
        
        NSString *requestPath = [NSString stringWithFormat:@"%@%@&friendId=%@&sessionKey=%@", BASE_PATH, ACCEPT_FRIEND_PATH, [userDict objectForKey:@"userID"], [[UserData sharedInstance] sessionKey]];
        NSURL *requestURL = [NSURL URLWithString:requestPath];
        NSURLRequest *requestReq = [NSURLRequest requestWithURL:requestURL];
        
        AFJSONRequestOperation *requestOp = [AFJSONRequestOperation JSONRequestOperationWithRequest:requestReq
                                                                                             success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                                 //JSON = [[JSON objectForKey:@"Nitro"] objectForKey:@"users"];
                                                                                                 //[self finishedLoadingFriends:JSON];
                                                                                             }
                                                                                             failure:nil];
        [requestOp start];

    
        [_tableData removeObjectAtIndex:indexPath.row];
        [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  FindFriendsViewController.m
//  LoyaltyPrototype
//
//  Created by Jason Grandelli on 2/19/13.
//  Copyright (c) 2013 URBN. All rights reserved.
//

#import "FindFriendsViewController.h"
#import "UIFont+UrbanAdditions.h"
#import <AFNetworking.h>
#import <MBProgressHUD.h>
#import "UserData.h"
#import <QuartzCore/QuartzCore.h>

#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>

#import <Parse/Parse.h>

@interface FindFriendsViewController ()

@property (nonatomic, strong) NSDictionary *currentFriends;
@property (nonatomic, strong) NSDictionary *pendingFriends;
@property (nonatomic, strong) NSMutableArray *tableData;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) UIButton *searchBtn;
@property (nonatomic, strong) UIButton *facebookBtn;
@property (nonatomic, strong) UIButton *twitterBtn;

@end

@implementation FindFriendsViewController

#define MARGIN 15.0f
#define PADDING 10.0f
#define IMAGE_SIZE 35.0f

#define BASE_PATH @"http://sandbox.bunchball.net/nitro/json?"
#define REQUEST_FRIEND_PATH @"method=user.inviteFriend&userId=16"
#define ACCEPT_FRIEND_PATH @"method=user.acceptFriend&userId=16"
#define DENY_FRIEND_PATH @"method=user.removeFriend&userId=16"


- (id)initWithCurrentFriends:(NSDictionary *)curFriends pending:(NSDictionary *)pending {
    self = [self init];
    
    if (nil != self) {
        self.currentFriends = curFriends;
        self.pendingFriends = pending;
    }
    
    return self;
}

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
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, 60.0)];
    backView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:backView];

    UILabel *searchLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    searchLbl.backgroundColor = [UIColor clearColor];
    searchLbl.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:14.0];
    searchLbl.text = @"Search";
    [searchLbl sizeToFit];
    
    UIImage *btnImg = [UIImage imageNamed:@"stretchableRoundedBtn"];
    UIEdgeInsets insets = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0);
    btnImg = [btnImg resizableImageWithCapInsets:insets];

    UIImage *btnSelectedImg = [UIImage imageNamed:@"stretchableRoundedBtn-selected"];
    btnSelectedImg = [btnSelectedImg resizableImageWithCapInsets:insets];

    self.searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _searchBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    _searchBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    _searchBtn.frame = CGRectMake(PADDING, PADDING, 88.0, 40.0);
    [_searchBtn setImage:btnImg forState:UIControlStateNormal];
    [_searchBtn setImage:btnSelectedImg forState:UIControlStateSelected];
    [_searchBtn addTarget:self action:@selector(showSearch) forControlEvents:UIControlEventTouchUpInside];
    [_searchBtn addSubview:searchLbl];
    
    CGRect frame = searchLbl.frame;
    frame.origin.x = _searchBtn.frame.size.width*.5 - frame.size.width*0.5;
    frame.origin.y = _searchBtn.frame.size.height*.5 - frame.size.height*0.5;
    searchLbl.frame = frame;
    
    [backView addSubview:_searchBtn];
    
    UILabel *facebookLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    facebookLbl.backgroundColor = [UIColor clearColor];
    facebookLbl.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:14.0];
    facebookLbl.text = @"Facebook";
    [facebookLbl sizeToFit];
    
    self.facebookBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _facebookBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    _facebookBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    _facebookBtn.frame = CGRectMake(_searchBtn.frame.origin.x + _searchBtn.frame.size.width + 18.0, PADDING, 88.0, 40.0);
    [_facebookBtn setImage:btnImg forState:UIControlStateNormal];
    [_facebookBtn setImage:btnSelectedImg forState:UIControlStateSelected];
    [_facebookBtn addTarget:self action:@selector(showFacebook) forControlEvents:UIControlEventTouchUpInside];
    [_facebookBtn addSubview:facebookLbl];
    
    frame = facebookLbl.frame;
    frame.origin.x = _facebookBtn.frame.size.width*.5 - frame.size.width*0.5;
    frame.origin.y = _facebookBtn.frame.size.height*.5 - frame.size.height*0.5;
    facebookLbl.frame = frame;
    
    [backView addSubview:_facebookBtn];
    
    UILabel *twitterLbl = [[UILabel alloc] initWithFrame:CGRectZero];
    twitterLbl.backgroundColor = [UIColor clearColor];
    twitterLbl.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:14.0];
    twitterLbl.text = @"Twitter";
    [twitterLbl sizeToFit];
    
    self.twitterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _twitterBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    _twitterBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    _twitterBtn.frame = CGRectMake(_facebookBtn.frame.origin.x + _facebookBtn.frame.size.width + 18.0, PADDING, 88.0, 40.0);
    [_twitterBtn setImage:btnImg forState:UIControlStateNormal];
    [_twitterBtn addTarget:self action:@selector(showTwitter) forControlEvents:UIControlEventTouchUpInside];
    [_twitterBtn addSubview:twitterLbl];
    
    frame = twitterLbl.frame;
    frame.origin.x = _twitterBtn.frame.size.width*.5 - frame.size.width*0.5;
    frame.origin.y = _twitterBtn.frame.size.height*.5 - frame.size.height*0.5;
    twitterLbl.frame = frame;
    
    [backView addSubview:_twitterBtn];
    
    self.tableData = [[NSMutableArray alloc] init];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, backView.frame.origin.y + backView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - backView.frame.size.height)];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.allowsSelection = NO;
    [self.view addSubview:_tableView];
    
    [self showSearch];
}

- (void)showSearch {
    _searchBtn.selected = YES;
    _facebookBtn.selected = NO;
    _twitterBtn.selected = NO;

     [_tableData removeAllObjects];
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 44.0)];
    _searchBar.delegate = self;
    [_tableView setTableHeaderView:_searchBar];
    [_tableView reloadData];
}

- (void)showFacebook {
    _searchBtn.selected = NO;
    _facebookBtn.selected = YES;
    _twitterBtn.selected = NO;
    
    [_tableData removeAllObjects];
    [_tableView setTableHeaderView:nil];
    [_tableView reloadData];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSLog(@"FBSession.activeSession.isOpen = %d", FBSession.activeSession.isOpen);
    if ( !FBSession.activeSession.isOpen ) {
        [appDelegate openSessionWithAllowLoginUI:YES delegate:self];
    }
    else {
        [self getFacebookFriends];
    }
}

- (void)showTwitter {
    _searchBtn.selected = NO;
    _facebookBtn.selected = NO;
    _twitterBtn.selected = YES;

    [_tableData removeAllObjects];
    [_tableView setTableHeaderView:nil];
    [_tableView reloadData];
}



- (void)facebookDidFinishLogin {
    [self getFacebookFriends];
}

- (void)getFacebookFriends {
    FBRequest *req = [FBRequest requestWithGraphPath:@"me/friends" parameters:@{@"fields":@"id,name,installed,picture"} HTTPMethod:@"GET"];
    [req startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        [_tableData removeAllObjects];
        
        for ( NSDictionary *userDict in [result objectForKey:@"data"] ) {
            if ( [userDict objectForKey:@"installed"] ) {
                NSString *fbID = [userDict objectForKey:@"id"];
                NSString *fbName = [userDict objectForKey:@"name"];
                NSString *picPath = [[[userDict objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
                
                NSMutableDictionary *fbUserDict = [[NSMutableDictionary alloc] init];
                [fbUserDict setValue:fbID forKey:@"fbID"];
                [fbUserDict setValue:fbName forKey:@"handle"];
                [fbUserDict setValue:picPath forKey:@"imgPath"];
                [fbUserDict setValue:@"" forKey:@"loyaltyID"];
                [_tableData addObject:fbUserDict];
                
                //Temp Parse stuff
                PFQuery *query = [PFQuery queryWithClassName:@"Users"];
                [query whereKey:@"facebookID" equalTo:fbID];
                [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    if ( !error && nil != object ) {
                        [fbUserDict setValue:[object objectForKey:@"loyaltyID"] forKey:@"loyaltyID"];
                    }
                }];
            }
        }
        
        [_tableView reloadData];
    }];
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
    
    btn = (UIButton *)[self.navigationController.navigationBar viewWithTag:2];
    [btn removeFromSuperview];
}

- (void)backBtnPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UISearchBarDelegate methods
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    _tableView.allowsSelection = NO;
    _tableView.scrollEnabled = NO;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar sizeToFit];
    searchBar.showsScopeBar = NO;
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text=@"";
    
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    _tableView.allowsSelection = YES;
    _tableView.scrollEnabled = YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    //searchBar.text=@"";
    
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    _tableView.allowsSelection = YES;
    _tableView.scrollEnabled = YES;
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

- (void)requestFriend:(id)sender event:(id)event {
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:currentTouchPosition];
    if (indexPath != nil){
        //[self tableView:_tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
        NSDictionary *userDict = [_tableData objectAtIndex:indexPath.row];
        NSString *loyaltyID = @"";
        
        if ( _searchBtn.selected ) {
            
        }
        else if ( _facebookBtn.selected ) {
            loyaltyID = [userDict objectForKey:@"loyaltyID"];
        }
        else if ( _twitterBtn.selected ) {
            
        }

        NSString *requestPath = [NSString stringWithFormat:@"%@%@&friendId=%@&sessionKey=%@", BASE_PATH, REQUEST_FRIEND_PATH, loyaltyID, [[UserData sharedInstance] sessionKey]];
        NSURL *requestURL = [NSURL URLWithString:requestPath];
        NSURLRequest *requestReq = [NSURLRequest requestWithURL:requestURL];
        
        AFJSONRequestOperation *requestOp = [AFJSONRequestOperation JSONRequestOperationWithRequest:requestReq
                                                                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                                //JSON = [[JSON objectForKey:@"Nitro"] objectForKey:@"users"];
                                                                                                //[self finishedLoadingFriends:JSON];
                                                                                            }
                                                                                            failure:nil];
        [requestOp start];

        /*
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
        */
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  LeaderboardViewController.m
//  LoyaltyPrototype
//
//  Created by Jason Grandelli on 12/28/12.
//  Copyright (c) 2012 URBN. All rights reserved.
//

#import "LeaderboardViewController.h"
#import "UIColor+ColorConstants.h"
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import <UIImageView+AFNetworking.h>
#import "NavBarItemsViewController.h"

@interface LeaderboardViewController ()

@property (nonatomic, strong) NSMutableArray *availableLeaderBoards;
@property (nonatomic) int currentLeaderBoard;
@property (nonatomic, strong) NSMutableArray *leaderList;
@property (nonatomic, strong) NSMutableDictionary *userDetails;
@property (nonatomic, strong) NSMutableArray *userFriends;

@property (nonatomic, strong) UIButton *dropDownBtn;
@property (nonatomic, strong) UIButton *friendsBtn;
@property (nonatomic, strong) UIView *greenLine;
@property (nonatomic, strong) UIView *userDataView;

@property (nonatomic, strong) UIView *pickerHolder;

@property (nonatomic, strong) UITableView *leaderTable;
@property (nonatomic, strong) NSMutableArray *tableDataArray;

@property (nonatomic, strong) NavBarItemsViewController *navBarItems;

@end

@implementation LeaderboardViewController

#define BASE_URL @"https://beta.bunchball.net/nitro/json?"
#define SESSION_KEY @"&sessionKey=NHwxMDQwNjJ8MTUzOTc3NjQwNDB8MTM1ODM0OTQ4NXxhOGEzYTI1NWI5ZWM0M2U0NTZlNmNhZWFmNTU2MTU2NmM1ZjRiMWNifDA="
#define USER_URL @"start=1356712240&withRank=true&duration=ALLTIME&criteria=CREDITS&pointCategory=Points&withSurroundingUsers=false&tags=&groupName=&returnCount=100&preferences=profile_name%7Cprofile_url%7Cgender&method=site%2EgetPointsLeaders&asyncToken=&tagsOperator=OR&userIds=123"
#define FRIENDS_URL @"method=user.getFriends&friendType=current&returnCount=100"
#define OVERALL_LEADERS_URL @"start=1356712240&withRank=false&duration=ALLTIME&criteria=BALANCE&pointCategory=Points&withSurroundingUsers=false&tags=&groupName=&returnCount=100&preferences=profile%5Fname%7Cprofile%5Furl%7Cgender&method=site%2EgetPointsLeaders&asyncToken=&tagsOperator=OR&userIds="
#define AVAILABLE_BOARDS_URL @"method=user.getChallengeProgress&showonlytrophies=false&showCanAchieveChallenge=true"
#define CHALLENGE_URL @"method=site.getActionLeaders&preferences=profile_name%7Cprofile_url&returnCount=100"
#define MARGIN 15.0f
#define IMAGE_SIZE 55.0f

//&criteria=count
//&tags=STORE_CHECKIN_WALNUT
//&duration=ALLTIME
//&tagsOperator=or

#pragma mark - UIViewController methods
- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.availableLeaderBoards = [[NSMutableArray alloc] init];
    self.leaderList = [[NSMutableArray alloc] init];
    self.userFriends = [[NSMutableArray alloc] init];
    self.currentLeaderBoard = 0;
    
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

    self.navBarItems = [[NavBarItemsViewController alloc] init];
    _navBarItems.view.frame = self.navigationController.navigationBar.bounds;
    [self.navigationController.navigationBar addSubview:_navBarItems.view];
    [_navBarItems updateInfo];
    
    CGFloat totalWidth = self.view.frame.size.width - (MARGIN * 2);
    
    UILabel *chooseLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN + 3.0, self.navigationController.navigationBar.frame.size.height + 5.0, 0, 0)];
    chooseLabel.backgroundColor = [UIColor clearColor];
    chooseLabel.textColor = [UIColor offWhite];
    chooseLabel.font = [UIFont systemFontOfSize:12.0];
    chooseLabel.text = @"Choose a leader board:";
    [chooseLabel sizeToFit];
    [self.view addSubview:chooseLabel];
    
    UIImage *dropDownImg = [UIImage imageNamed:@"dropDownBG"];
    self.dropDownBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _dropDownBtn.frame = CGRectMake(MARGIN, chooseLabel.frame.size.height + chooseLabel.frame.origin.y + 5.0, dropDownImg.size.width, dropDownImg.size.height);
    [_dropDownBtn setImage:dropDownImg forState:UIControlStateNormal];
    [_dropDownBtn addTarget:self action:@selector(dropDownPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_dropDownBtn];
    
    UILabel *dropDownLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 5.0, 0.0, 0.0)];
    dropDownLabel.backgroundColor = [UIColor clearColor];
    dropDownLabel.textColor = [UIColor offWhite];
    dropDownLabel.font = [UIFont systemFontOfSize:14.0];
    dropDownLabel.text = @"Overall";
    [dropDownLabel sizeToFit];
    dropDownLabel.tag = 1;
    [_dropDownBtn addSubview:dropDownLabel];
    
    UIImage *friendToggleImg = [UIImage imageNamed:@"friendsToggleBtn"];
    self.friendsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _friendsBtn.frame = CGRectMake(totalWidth - friendToggleImg.size.width*.5,
                                        _dropDownBtn.frame.origin.y,
                                        friendToggleImg.size.width,
                                        friendToggleImg.size.height);
    [_friendsBtn setImage:friendToggleImg forState:UIControlStateNormal];
    [_friendsBtn setImage:[UIImage imageNamed:@"friendsToggleBtnSelected"] forState:UIControlStateSelected];
    [_friendsBtn addTarget:self action:@selector(friendsTogglePressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_friendsBtn];
    
    UILabel *friendsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, chooseLabel.frame.origin.y, 0.0, 0.0)];
    friendsLabel.backgroundColor = [UIColor clearColor];
    friendsLabel.textColor = [UIColor offWhite];
    friendsLabel.font = [UIFont systemFontOfSize:12.0];
    friendsLabel.text = @"Friends only?";
    [friendsLabel sizeToFit];
    CGRect frame = friendsLabel.frame;
    frame.origin.x = roundf((_friendsBtn.frame.origin.x + _friendsBtn.bounds.size.width) - frame.size.width);
    friendsLabel.frame = frame;
    [self.view addSubview:friendsLabel];
    
    
    self.greenLine = [[UIView alloc] initWithFrame:CGRectMake(MARGIN,
                                                                 _dropDownBtn.frame.origin.y + _dropDownBtn.frame.size.height + MARGIN,
                                                                 totalWidth,
                                                                 1.0)];
    _greenLine.backgroundColor = [UIColor neonGreen];
    _greenLine.alpha = 0.3;
    [self.view addSubview:_greenLine];

    self.leaderTable = [[UITableView alloc] initWithFrame:CGRectMake(MARGIN,
                                                                   _greenLine.frame.origin.y + 1.0,
                                                                   self.view.frame.size.width - 30.0,
                                                                   self.view.frame.size.height - _greenLine.frame.origin.y - 1.0)];
    _leaderTable.dataSource = self;
    _leaderTable.delegate = self;
    _leaderTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    _leaderTable.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_leaderTable];
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *userPath = [NSString stringWithFormat:@"%@%@%@", BASE_URL, USER_URL, SESSION_KEY];
    NSURL *userURL = [NSURL URLWithString:userPath];
    NSURLRequest *userReq = [NSURLRequest requestWithURL:userURL];
    AFJSONRequestOperation *userOp = [AFJSONRequestOperation JSONRequestOperationWithRequest:userReq
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            JSON = [JSON objectForKey:@"Nitro"];
                                                                                            JSON = [JSON objectForKey:@"leaders"];
                                                                                            JSON = [JSON objectForKey:@"Leader"];
                                                                                            [self finishedLoadingUserData:JSON];
                                                                                        }
                                                                                        failure:nil];

    NSString *friendsPath = [NSString stringWithFormat:@"%@%@%@", BASE_URL, FRIENDS_URL, SESSION_KEY];
    NSURL *friendsURL = [NSURL URLWithString:friendsPath];
    NSURLRequest *friendsReq = [NSURLRequest requestWithURL:friendsURL];
    AFJSONRequestOperation *friendsOp = [AFJSONRequestOperation JSONRequestOperationWithRequest:friendsReq
                                                                                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                         JSON = [JSON objectForKey:@"Nitro"];
                                                                                         JSON = [JSON objectForKey:@"users"];
                                                                                         [self finishedLoadingFriends:JSON];
                                                                                     }
                                                                                     failure:nil];
    
    
    NSString *leaderBoardPath = [NSString stringWithFormat:@"%@%@%@", BASE_URL, OVERALL_LEADERS_URL, SESSION_KEY];
    NSURL *leaderBoardURL = [NSURL URLWithString:leaderBoardPath];
    NSURLRequest *leaderBoardReq = [NSURLRequest requestWithURL:leaderBoardURL];
    AFJSONRequestOperation *leaderBoardOp = [AFJSONRequestOperation JSONRequestOperationWithRequest:leaderBoardReq
                                                                                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                         JSON = [JSON objectForKey:@"Nitro"];
                                                                                         JSON = [JSON objectForKey:@"leaders"];
                                                                                         [self parseOverallLeaderBoard:JSON];
                                                                                     }
                                                                                     failure:nil];
    
    NSString *availableBoardsPath = [NSString stringWithFormat:@"%@%@%@", BASE_URL, AVAILABLE_BOARDS_URL, SESSION_KEY];
    NSURL *availableBoardsURL = [NSURL URLWithString:availableBoardsPath];
    NSURLRequest *availableBoardsReq = [NSURLRequest requestWithURL:availableBoardsURL];
    AFJSONRequestOperation *availableBoardsOp = [AFJSONRequestOperation JSONRequestOperationWithRequest:availableBoardsReq
                                                                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                                JSON = [JSON objectForKey:@"Nitro"];
                                                                                                JSON = [JSON objectForKey:@"challenges"];
                                                                                                [self finishedLoadingAvailableBoards:JSON];
                                                                                            }
                                                                                            failure:nil];
    
    
    NSArray *opArray = @[userOp, leaderBoardOp, friendsOp, availableBoardsOp];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    [client enqueueBatchOfHTTPRequestOperations:opArray
                                  progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
                                      nil;
                                  }
                                completionBlock:^(NSArray *operations) {
                                    [self finishedBatchOperationBatch];
                                }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Data Processing methods
- (void)getLeaderBoardData {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    NSString *leaderBoardPath = nil;

    if ( _currentLeaderBoard == 0 ) {
        leaderBoardPath = [NSString stringWithFormat:@"%@%@%@", BASE_URL, OVERALL_LEADERS_URL, SESSION_KEY];
    }
    else {
        NSDictionary *dict = [_availableLeaderBoards objectAtIndex:_currentLeaderBoard];
        NSString *criteria = [dict objectForKey:@"criteria"];
        NSString *tag = [[dict objectForKey:@"tag"] uppercaseString];
        NSString *operator = [dict objectForKey:@"operator"];
        NSString *duration = [[dict objectForKey:@"duration"] uppercaseString];
        NSString *parameters = [NSString stringWithFormat:@"&criteria=%@&tags=%@&duration=%@&tagsOperator=%@", criteria, tag, duration, operator];
        leaderBoardPath = [NSString stringWithFormat:@"%@%@%@%@", BASE_URL, CHALLENGE_URL, SESSION_KEY, parameters];
    }

    NSURL *leaderBoardURL = [NSURL URLWithString:leaderBoardPath];
    NSURLRequest *leaderBoardReq = [NSURLRequest requestWithURL:leaderBoardURL];
    AFJSONRequestOperation *leaderBoardOp = [AFJSONRequestOperation JSONRequestOperationWithRequest:leaderBoardReq
                                                                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                                JSON = [JSON objectForKey:@"Nitro"];
                                                                                                [self finishedLoadingLeaderBoard:JSON];
                                                                                            }
                                                                                            failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                                                                NSLog(@"%@", error);
                                                                                            }];
    
    [leaderBoardOp start];
}

- (void)finishedLoadingUserData:(NSDictionary *)JSON {
    int points = [[JSON objectForKey:@"points"] intValue];
    NSString *formattedPoints = [self formattedPointsFromInt:points];
    int rank = [[JSON objectForKey:@"rank"] intValue];
    NSString *userID = [JSON objectForKey:@"userId"];
    NSString *gender = nil;
    NSString *handle = nil;
    NSString *picPath = nil;
    
    
    NSArray *prefs = [[JSON objectForKey:@"UserPreferences"] objectForKey:@"UserPreference"];
    
    for ( NSDictionary *dict in prefs ) {
        if ( [[dict objectForKey:@"name"] isEqual:@"gender"] ) gender = [dict objectForKey:@"value"];
        else if ( [[dict objectForKey:@"name"] isEqual:@"profile_name"] ) handle = [dict objectForKey:@"value"];
        else if ( [[dict objectForKey:@"name"] isEqual:@"profile_url"] ) picPath = [dict objectForKey:@"value"];
    }
    
    self.userDetails = [[NSMutableDictionary alloc] init];
    [_userDetails setValue:userID forKey:@"userID"];
    [_userDetails setValue:[NSNumber numberWithInt:points] forKey:@"points"];
    [_userDetails setValue:formattedPoints forKey:@"formattedPoints"];
    [_userDetails setValue:[NSNumber numberWithInt:rank] forKey:@"rank"];
    [_userDetails setValue:gender forKey:@"gender"];
    [_userDetails setValue:handle forKey:@"handle"];
    [_userDetails setValue:picPath forKey:@"picPath"];
    
    UIImageView *profileImageView;
    UILabel *handleLabel;
    UILabel *pointsLabel;
    UILabel *levelLabel;
    
    if ( !_userDataView ) {
        self.userDataView = [[UIView alloc] initWithFrame:CGRectMake(MARGIN,
                                                                     _dropDownBtn.frame.origin.y + _dropDownBtn.frame.size.height + 5.0,
                                                                     self.view.frame.size.width - MARGIN * 2,
                                                                     IMAGE_SIZE + 20.0)];
        _userDataView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        

        profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, IMAGE_SIZE, IMAGE_SIZE)];
        profileImageView.tag = 1;
        [_userDataView addSubview:profileImageView];
        
        handleLabel = [[UILabel alloc] initWithFrame:CGRectMake(profileImageView.frame.origin.x + profileImageView.frame.size.width + 15.0,
                                                                profileImageView.frame.origin.y - 1.0,
                                                                0.0,
                                                                0.0)];
        handleLabel.backgroundColor = [UIColor clearColor];
        handleLabel.font = [UIFont systemFontOfSize:18.0];
        handleLabel.tag = 2;
        [_userDataView addSubview:handleLabel];
        
        pointsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        pointsLabel.backgroundColor = [UIColor clearColor];
        pointsLabel.font = [UIFont boldSystemFontOfSize:13.0];
        pointsLabel.textColor = [UIColor offWhite];
        pointsLabel.tag = 3;
        [_userDataView addSubview:pointsLabel];
        
        levelLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        levelLabel.backgroundColor = [UIColor clearColor];
        levelLabel.font = [UIFont boldSystemFontOfSize:13.0];
        levelLabel.textColor = [UIColor neonGreen];
        levelLabel.alpha = 0.5;
        levelLabel.tag = 4;
        [_userDataView addSubview:levelLabel];
    }

    if ( !profileImageView ) profileImageView = (UIImageView *)[_userDataView viewWithTag:1];
    [profileImageView setImageWithURL:[NSURL URLWithString:picPath] placeholderImage:[UIImage imageNamed:@"profileHolderImg"]];
    
    if ( !handleLabel ) handleLabel = (UILabel *)[_userDataView viewWithTag:2];
    handleLabel.text = [NSString stringWithFormat:@"%i: %@ (you)", rank, [handle uppercaseString]];
    if ( [gender isEqualToString:@"M"] ) handleLabel.textColor = [UIColor neonBlue];
    else if ( [gender isEqualToString:@"F"] ) handleLabel.textColor = [UIColor neonPink];
    else handleLabel.textColor = [UIColor neonGreen];
    [handleLabel sizeToFit];
    
    if ( !pointsLabel ) pointsLabel = (UILabel *)[_userDataView viewWithTag:3];
    pointsLabel.frame = CGRectMake(handleLabel.frame.origin.x, handleLabel.frame.origin.y + handleLabel.frame.size.height + 2.0, 0.0, 0.0);
    pointsLabel.text = [NSString stringWithFormat:@"%@ points.", formattedPoints];
    [pointsLabel sizeToFit];
    
    if ( !levelLabel ) levelLabel = (UILabel *)[_userDataView viewWithTag:4];
    levelLabel.frame = CGRectMake(pointsLabel.frame.origin.x, pointsLabel.frame.origin.y + pointsLabel.frame.size.height + 2.0, 0.0, 0.0);
    NSString *levelText = nil;
    if ( points < 501 ) levelText = @"Trend Setta";
    else if ( points < 1001 ) levelText = @"Super Being";
    else if (points < 2001 ) levelText = @"Hipster General";
    else levelText = @"URBAN Legend";
    
    levelLabel.text = levelText;
    [levelLabel sizeToFit];
    
    CGRect frame = _greenLine.frame;
    frame.origin.y = _userDataView.frame.origin.y + _userDataView.frame.size.height + 5.0;
    _greenLine.frame = frame;
    
    _leaderTable.frame = CGRectMake(MARGIN,
                                    _greenLine.frame.origin.y + 1.0,
                                    self.view.frame.size.width - 30.0,
                                    self.view.frame.size.height - _greenLine.frame.origin.y - 1.0);
}

- (void)finishedLoadingFriends:(NSDictionary *)JSON {
    [_userFriends removeAllObjects];
    for ( NSDictionary *dict in [JSON objectForKey:@"User"]) {
        NSString *userID = [dict objectForKey:@"userId"];
        [_userFriends addObject:userID];
    }
}

- (void)finishedLoadingLeaderBoard:(NSDictionary *)JSON {
    CGRect frame = _greenLine.frame;
    if ( _currentLeaderBoard == 0 ) {
        JSON = [JSON objectForKey:@"leaders"];
        [self parseOverallLeaderBoard:JSON];
        [self.view addSubview:_userDataView];
        frame.origin.y = _userDataView.frame.origin.y + _userDataView.frame.size.height + 5.0;
    }
    else {
        JSON = [JSON objectForKey:@"actions"];
        [self parseChallengeLeaderBoard:JSON];
        [_userDataView removeFromSuperview];
        frame.origin.y = _dropDownBtn.frame.origin.y + _dropDownBtn.frame.size.height + 10.0;
    }
    
    _greenLine.frame = frame;
    
    frame = _leaderTable.frame;
    frame.origin.y = _greenLine.frame.origin.y + 1.0;
    frame.size.height = self.view.frame.size.height - _greenLine.frame.origin.y - 1.0;
    _leaderTable.frame = frame;
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [_leaderTable reloadData];
}

- (void)parseOverallLeaderBoard:(NSDictionary *)JSON {
    //*
    [_leaderList removeAllObjects];
    
    for ( NSDictionary *dict in [JSON objectForKey:@"Leader"] ) {
        NSString *userID = [dict objectForKey:@"userId"];
        int points = [[dict objectForKey:@"points"] intValue];
        NSString *formattedPoints = [self formattedPointsFromInt:points];
        
        NSString *gender = nil;
        NSString *handle = nil;
        NSString *picPath = nil;

        if ( [[dict objectForKey:@"UserPreferences"] isKindOfClass:[NSDictionary class]] ) {
            for ( NSDictionary *prefDict in [[dict objectForKey:@"UserPreferences"] objectForKey:@"UserPreference"] ) {
                if ( [[prefDict objectForKey:@"name"] isEqual:@"gender"] ) gender = [prefDict objectForKey:@"value"];
                else if ( [[prefDict objectForKey:@"name"] isEqual:@"profile_name"] ) handle = [prefDict objectForKey:@"value"];
                else if ( [[prefDict objectForKey:@"name"] isEqual:@"profile_url"] ) picPath = [prefDict objectForKey:@"value"];
            }
        }

        NSMutableDictionary *userDict = [[NSMutableDictionary alloc] init];
        [userDict setValue:userID forKey:@"userID"];
        [userDict setValue:[NSNumber numberWithInt:points] forKey:@"points"];
        [userDict setValue:formattedPoints forKey:@"formattedPoints"];
        [userDict setValue:gender forKey:@"gender"];
        [userDict setValue:handle forKey:@"handle"];
        [userDict setValue:picPath forKey:@"picPath"];
        
        [_leaderList addObject:userDict];
    }
    
    [self.tableDataArray removeAllObjects];

    if ( _friendsBtn.selected ) {
        for ( int i = 0; i < [_leaderList count]; ++i ) {
            NSDictionary *user = [_leaderList objectAtIndex:i];
            NSString *userID = [user objectForKey:@"userID"];
            if ( [_userFriends containsObject:userID] ) [_tableDataArray addObject:user];
        }
    }
    else self.tableDataArray = [NSMutableArray arrayWithArray:_leaderList];
    //*/
}

- (void)parseChallengeLeaderBoard:(NSDictionary *)JSON {
    [_leaderList removeAllObjects];

    for ( NSDictionary *user in [JSON objectForKey:@"Action"] ) {
        NSString *userID = [user objectForKey:@"userId"];
        int points = [[user objectForKey:@"value"] intValue];
        NSString *formattedPoints = [self formattedPointsFromInt:points];
        
        NSString *handle = nil;
        NSString *picPath = nil;
        NSString *gender = @"U";

        for ( NSDictionary *prefDict in [[user objectForKey:@"UserPreferences"] objectForKey:@"UserPreference"] ) {
            if ( [[prefDict objectForKey:@"name"] isEqual:@"gender"] ) gender = [prefDict objectForKey:@"value"];
            if ( [[prefDict objectForKey:@"name"] isEqual:@"profile_name"] ) handle = [prefDict objectForKey:@"value"];
            else if ( [[prefDict objectForKey:@"name"] isEqual:@"profile_url"] ) picPath = [prefDict objectForKey:@"value"];
        }

        NSMutableDictionary *userDict = [[NSMutableDictionary alloc] init];
        [userDict setValue:userID forKey:@"userID"];
        [userDict setValue:[NSNumber numberWithInt:points] forKey:@"points"];
        [userDict setValue:formattedPoints forKey:@"formattedPoints"];
        [userDict setValue:gender forKey:@"gender"];
        [userDict setValue:handle forKey:@"handle"];
        [userDict setValue:picPath forKey:@"picPath"];
        
        [_leaderList addObject:userDict];
    }
    
    [self.tableDataArray removeAllObjects];
    
    if ( _friendsBtn.selected ) {
        for ( int i = 0; i < [_leaderList count]; ++i ) {
            NSDictionary *user = [_leaderList objectAtIndex:i];
            NSString *userID = [user objectForKey:@"userID"];
            if ( [_userFriends containsObject:userID] ) [_tableDataArray addObject:user];
        }
    }
    else self.tableDataArray = [NSMutableArray arrayWithArray:_leaderList];
}

- (void)finishedLoadingAvailableBoards:(NSDictionary *)JSON {
    [_availableLeaderBoards removeAllObjects];
    
    NSDictionary *overallDictionary = @{ @"name":@"Overall" };
    [_availableLeaderBoards addObject:overallDictionary];
    
    for ( NSDictionary *challenge in [JSON objectForKey:@"Challenge"] ) {
        NSString *customDataString = [challenge objectForKey:@"customData"];
        
        if ( customDataString && [customDataString rangeOfString:@"leaderboard:YES"].location != NSNotFound ) {
            NSArray *customDataArray = [customDataString componentsSeparatedByString:@","];
            NSDictionary *leaderBoardData = [[NSMutableDictionary alloc] init];
            [leaderBoardData setValue:[challenge objectForKey:@"name"] forKey:@"name"];
            
            for ( int i = 0; i < [customDataArray count]; ++i ) {
                NSString *pair = [customDataArray objectAtIndex:i];
                NSUInteger colonInt = [pair rangeOfString:@":"].location;
                NSString *key = [pair substringToIndex:colonInt];
                NSString *value = [pair substringFromIndex:colonInt + 1];
                
                if ( [key isEqualToString:@"actiontag"] ) [leaderBoardData setValue:value forKey:@"tag"];
                else if ( [key isEqualToString:@"actiontagcriteria"] ) [leaderBoardData setValue:value forKey:@"criteria"];
                else if ( [key isEqualToString:@"actiontagoperator"] ) [leaderBoardData setValue:value forKey:@"operator"];
                else if ( [key isEqualToString:@"duration"] ) [leaderBoardData setValue:value forKey:@"duration"];
                else if ( [key isEqualToString:@"qualifier"] ) [leaderBoardData setValue:value forKey:@"qualifier"];
            }
            
            [_availableLeaderBoards addObject:leaderBoardData];
        }
    }
}

- (void)finishedBatchOperationBatch {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [_leaderTable reloadData];
    
    [self.view addSubview:_userDataView];
}

#pragma mark - UIButton Action methods
- (void)dropDownPressed:(id)sender {
    UIPickerView *picker = nil;
    UIButton *goBtn = nil;
    UIButton *cancelBtn = nil;
    
    if ( !self.pickerHolder ) {
        self.pickerHolder = [[UIView alloc] init];
        //_pickerHolder.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        
        UIButton *catcher = [UIButton buttonWithType:UIButtonTypeCustom];
        catcher.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
        [catcher addTarget:self action:@selector(cancelDropdownTouched:) forControlEvents:UIControlEventTouchUpInside];
        [_pickerHolder addSubview:catcher];
        
        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 240.0, self.view.frame.size.width, 240.0)];
        background.backgroundColor = [UIColor blackColor];
        [_pickerHolder addSubview:background];
        
        picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, background.frame.origin.y + 40.0, [UIScreen mainScreen].bounds.size.width, 200.0)];
        picker.tag = 1;
        picker.showsSelectionIndicator = YES;
        [_pickerHolder addSubview:picker];
        
        UIImage *selectImg = [UIImage imageNamed:@"selectBtn"];
        goBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [goBtn setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - selectImg.size.width - 5.0, background.frame.origin.y + 6.0, selectImg.size.width, selectImg.size.height)];
        [goBtn setImage:selectImg forState:UIControlStateNormal];
        [goBtn addTarget:self action:@selector(selectBoardTouched:) forControlEvents:UIControlEventTouchUpInside];
        [_pickerHolder addSubview:goBtn];

        UIImage *cancelImg = [UIImage imageNamed:@"cancelBtn"];
        cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelBtn setFrame:CGRectMake(5.0, background.frame.origin.y + 6.0, cancelImg.size.width, cancelImg.size.height)];
        [cancelBtn setImage:cancelImg forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancelDropdownTouched:) forControlEvents:UIControlEventTouchUpInside];
        [_pickerHolder addSubview:cancelBtn];
    }
    
    if ( !picker ) picker = (UIPickerView *)[_pickerHolder viewWithTag:1];
    picker.dataSource = self;
    picker.delegate = self;
    picker.showsSelectionIndicator = YES;
    [picker selectRow:_currentLeaderBoard inComponent:0 animated:NO];
    
    _pickerHolder.frame = CGRectMake(0.0, self.view.frame.size.height, [UIScreen mainScreen].bounds.size.width, self.view.frame.size.height);
    
    [self.view addSubview:_pickerHolder];
    [UIView animateWithDuration:.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                         CGRect frame = _pickerHolder.frame;
                         frame.origin.y = 0.0;
                         _pickerHolder.frame = frame;
                     }
                     completion:^(BOOL finished) {
                     }];
    
    //[self.view addSubview:picker];
}

- (void)friendsTogglePressed:(id)sender {
    UIButton *btn = sender;
    btn.selected = !btn.selected;
    
    [self.tableDataArray removeAllObjects];
    
    if ( btn.selected ) {
        for ( int i = 0; i < [_leaderList count]; ++i ) {
            NSDictionary *user = [_leaderList objectAtIndex:i];
            NSString *userID = [user objectForKey:@"userID"];
            if ( [_userFriends containsObject:userID] ) [_tableDataArray addObject:user];
        }
    }
    else {
        self.tableDataArray = [NSMutableArray arrayWithArray:_leaderList];
    }

    [_leaderTable reloadData];
}

- (void)cancelDropdownTouched:(id)sender {
    UIPickerView *picker = (UIPickerView *)[_pickerHolder viewWithTag:1];
    [picker selectRow:_currentLeaderBoard inComponent:0 animated:YES];
    [self animateOutPickerHolder];
}

- (void)selectBoardTouched:(id)sender {
    UIPickerView *picker = (UIPickerView *)[_pickerHolder viewWithTag:1];
    int ind = [picker selectedRowInComponent:0];
    if (_currentLeaderBoard != ind ) {
        self.currentLeaderBoard = ind;
        [self getLeaderBoardData];
        UILabel *lbl = (UILabel *)[_dropDownBtn viewWithTag:1];
        CGRect frame = lbl.frame;
        frame.size.width = _dropDownBtn.frame.size.width - 45.0;
        lbl.frame = frame;
        lbl.text = [[_availableLeaderBoards objectAtIndex:ind] objectForKey:@"name"];
    }
    [self animateOutPickerHolder];
}

- (void)animateOutPickerHolder {
    [UIView animateWithDuration:.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                         CGRect frame = _pickerHolder.frame;
                         frame.origin.y = self.view.frame.size.height;
                         _pickerHolder.frame = frame;
                     }
                     completion:^(BOOL finished) {
                         [_pickerHolder removeFromSuperview];
                     }];
}

#pragma mark - UITableViewDelegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return IMAGE_SIZE + 20.0;
}

#pragma mark - UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_tableDataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
    UIImageView *profileImageView = nil;
    UILabel *handleLabel = nil;
    UILabel *pointsLabel = nil;
    UILabel *levelLabel = nil;
    
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        
        UIView *selView = [[UIView alloc] initWithFrame:cell.frame];
        selView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        cell.selectedBackgroundView = selView;

        profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, IMAGE_SIZE, IMAGE_SIZE)];
        profileImageView.tag = 1;
        [[cell contentView] addSubview:profileImageView];
        
        handleLabel = [[UILabel alloc] initWithFrame:CGRectMake(profileImageView.frame.origin.x + profileImageView.frame.size.width + 15.0,
                                                                profileImageView.frame.origin.y - 1.0,
                                                                0.0,
                                                                0.0)];
        handleLabel.backgroundColor = [UIColor clearColor];
        handleLabel.font = [UIFont systemFontOfSize:18.0];
        handleLabel.tag = 2;
        [[cell contentView] addSubview:handleLabel];
        
        pointsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        pointsLabel.backgroundColor = [UIColor clearColor];
        pointsLabel.font = [UIFont boldSystemFontOfSize:13.0];
        pointsLabel.textColor = [UIColor offWhite];
        pointsLabel.tag = 3;
        [[cell contentView] addSubview:pointsLabel];
        
        levelLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        levelLabel.backgroundColor = [UIColor clearColor];
        levelLabel.font = [UIFont boldSystemFontOfSize:13.0];
        levelLabel.textColor = [UIColor neonGreen];
        levelLabel.alpha = 0.5;
        levelLabel.tag = 4;
        [[cell contentView] addSubview:levelLabel];
    }
    
    
    NSDictionary *userDict = [_tableDataArray objectAtIndex:indexPath.row];
    
    if ( !profileImageView ) profileImageView = (UIImageView *)[cell viewWithTag:1];
    [profileImageView setImageWithURL:[NSURL URLWithString:[userDict objectForKey:@"picPath"]] placeholderImage:[UIImage imageNamed:@"profileHolderImg"]];
    
    if ( !handleLabel ) handleLabel = (UILabel *)[cell viewWithTag:2];
    if ( _currentLeaderBoard == 0 ) handleLabel.frame = CGRectMake(profileImageView.frame.origin.x + profileImageView.frame.size.width + 15.0,
                                                                   profileImageView.frame.origin.y - 1.0,
                                                                   0.0,
                                                                   0.0);
    else handleLabel.frame = CGRectMake(profileImageView.frame.origin.x + profileImageView.frame.size.width + 15.0,
                    profileImageView.frame.origin.y + 5.0,
                    0.0,
                    0.0);
    
    handleLabel.text = [NSString stringWithFormat:@"%i: %@", indexPath.row + 1, [[userDict objectForKey:@"handle"] uppercaseString]];
    if ( [[userDict objectForKey:@"gender"] isEqualToString:@"M"] ) handleLabel.textColor = [UIColor neonBlue];
    else if ( [[userDict objectForKey:@"gender"] isEqualToString:@"F"] ) handleLabel.textColor = [UIColor neonPink];
    else handleLabel.textColor = [UIColor neonGreen];
    [handleLabel sizeToFit];
    
    if ( !pointsLabel ) pointsLabel = (UILabel *)[cell viewWithTag:3];
    
    NSString *pointsText = nil;
    if ( _currentLeaderBoard == 0 ) {
        pointsLabel.font = [UIFont boldSystemFontOfSize:13.0];
        pointsLabel.frame = CGRectMake(handleLabel.frame.origin.x, handleLabel.frame.origin.y + handleLabel.frame.size.height + 2.0, 0.0, 0.0);
        pointsText = [NSString stringWithFormat:@"%@ points.", [userDict objectForKey:@"formattedPoints"]];
    }
    else {
        pointsLabel.font = [UIFont boldSystemFontOfSize:15.0];
        pointsLabel.frame = CGRectMake(handleLabel.frame.origin.x, handleLabel.frame.origin.y + handleLabel.frame.size.height + 6.0, 0.0, 0.0);
        NSString *qualifier = [[_availableLeaderBoards objectAtIndex:_currentLeaderBoard] objectForKey:@"qualifier"];
        pointsText = [NSString stringWithFormat:@"%@ %@.", [userDict objectForKey:@"formattedPoints"], qualifier];
    }
    
    pointsLabel.text = pointsText;
    [pointsLabel sizeToFit];
    
    if ( !levelLabel ) levelLabel = (UILabel *)[cell viewWithTag:4];
    
    if ( _currentLeaderBoard == 0 ) {
        levelLabel.alpha = 0.5;
        levelLabel.frame = CGRectMake(pointsLabel.frame.origin.x, pointsLabel.frame.origin.y + pointsLabel.frame.size.height + 2.0, 0.0, 0.0);
        
        NSString *levelText = nil;
        int points = [[userDict objectForKey:@"points"] intValue];
        if ( points < 501 ) levelText = @"Trend Setta";
        else if ( points < 1001 ) levelText = @"Super Being";
        else if (points < 2001 ) levelText = @"Hipster General";
        else levelText = @"URBAN Legend";
        
        levelLabel.text = levelText;
        [levelLabel sizeToFit];
    }
    else levelLabel.alpha = 0.0;
    
	return cell;
}

#pragma mark - UIPickerViewDataSource methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [_availableLeaderBoards count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSDictionary *boardData = [_availableLeaderBoards objectAtIndex:row];
    return [boardData objectForKey:@"name"];
}

#pragma mark - UIPickerViewDelegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
}

#pragma mark - Utility methods
- (NSString *)formattedPointsFromInt:(int)pointInt {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSString *formattedString = [formatter stringFromNumber:[NSNumber numberWithInt:pointInt]];
    
    return formattedString;
}

@end

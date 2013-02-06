//
//  VenueListViewController.m
//  LoyaltyPrototype
//
//  Created by Jason Grandelli on 1/24/13.
//  Copyright (c) 2013 URBN. All rights reserved.
//

#import "VenueListViewController.h"
#import "CheckInViewController.h"
#import "UIFont+UrbanAdditions.h"
#import <AFNetworking.h>

@interface VenueListViewController ()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UITableView *venueTable;
@property (nonatomic) BOOL locationFound;
@property (nonatomic) int locCount;

@end

@implementation VenueListViewController

#define MARGIN 15.0f
#define BASE_FOURSQUARE_URL @"https://api.foursquare.com/v2/venues/search?intent=browse&limit=50&radius=200" //&query=office
#define FOURSQUARE_ID @"&client_id=4LW2FXUPV1BB002XVNFEUUKQMC23B1V5J0STJZKMFIRRSWF0"
#define FOURSQUARE_SECRET @"&client_secret=YRCRCNOZRYYVKZRRLVCZJ2VGYUM3OWGZWD1FQNDOT2LCLVEP"

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.navigationItem setHidesBackButton:YES];
    
    int i = (arc4random() % 4) + 1;
    NSString *patternName = [NSString stringWithFormat:@"Background%i", i];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:patternName]];
    
    self.dataArray = [[NSMutableArray alloc] init];
    [_dataArray addObject:@"searching"];
    [_dataArray addObject:@"credit"];
    
    //CGFloat totalWidth = self.view.frame.size.width - MARGIN*2;
    self.venueTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0,
                                                                    self.navigationController.navigationBar.frame.size.height,
                                                                    self.view.frame.size.width,
                                                                    self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height)];
    _venueTable.rowHeight = 54.0;
    _venueTable.dataSource = self;
    _venueTable.delegate = self;
    [self.view addSubview:_venueTable];
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
    [rightBtn addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.tag = 2;
    [self.navigationController.navigationBar addSubview:rightBtn];

    self.locCount = 0;
    
    self.locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [_locationManager startUpdatingLocation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    UIButton *btn = (UIButton *)[self.navigationController.navigationBar viewWithTag:1];
    [btn removeFromSuperview];
    
    btn = (UIButton *)[self.navigationController.navigationBar viewWithTag:2];
    [btn removeFromSuperview];

    [self stopUpdatingLocation:@"found"];
}

- (void)backBtnPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.location = _locationManager.location;
    //[self stopUpdatingLocation:@"found"];
    self.locCount++;
    if ( !_locationFound && _locCount == 3 ) [self getVenues];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([error code] != kCLErrorLocationUnknown) {
        [self stopUpdatingLocation:NSLocalizedString(@"Error", @"Error")];
    }
}

- (void)stopUpdatingLocation:(NSString *)state {
    [_locationManager stopUpdatingLocation];
    _locationManager.delegate = nil;
}

- (void)refreshData {
    [self getVenues];
}

- (void)getVenues {
    self.locationFound = YES;
    
    CGFloat lat = _location.coordinate.latitude;
    CGFloat lon = _location.coordinate.longitude;
    //lat = 39.890040;
    //lon = -75.178404;
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@&ll=%f,%f", BASE_FOURSQUARE_URL, FOURSQUARE_ID, FOURSQUARE_SECRET, lat, lon];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setTimeoutInterval:30];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:req
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                            [self sortVenues:[JSON objectForKey:@"response"]];
                                                                                        }
                                                                                        failure:nil];
    [operation start];
    
}

- (void)sortVenues:(NSDictionary *)JSON {
    //NSLog(@"JSON = %@", [JSON objectForKey:@"groups"]);
    NSArray * arr = [[[JSON objectForKey:@"groups"] objectAtIndex:0] objectForKey:@"items"];
    
    [_dataArray removeAllObjects];
    
    for ( NSDictionary *item in arr ) {
        NSMutableDictionary *venueDict = [[NSMutableDictionary alloc] init];
        
        NSString *venueID = [item objectForKey:@"id"];
        NSString *venueName = [item objectForKey:@"name"];
        NSString *venueLocation = [[item objectForKey:@"location"] objectForKey:@"address"];
        //NSLog(@"venue location = %@", [item objectForKey:@"location"]);
        if ( !venueLocation ) {
            venueLocation = [NSString stringWithFormat:@"%@, %@", [[item objectForKey:@"location"] objectForKey:@"city"], [[item objectForKey:@"location"] objectForKey:@"state"]];
        }
        
        [venueDict setObject:venueID forKey:@"venueID"];
        [venueDict setObject:venueName forKey:@"venueName"];
        [venueDict setObject:venueLocation forKey:@"venueLocation"];
        
        [_dataArray addObject:venueDict];
    }
    
    [_dataArray addObject:@"credit"];
    
    [_venueTable reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
    UIImageView *creditImgView = nil;
    UILabel *nameLabel = nil;
    UILabel *locationLabel = nil;
    
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        
        UIView *selView = [[UIView alloc] initWithFrame:cell.frame];
        selView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
        cell.selectedBackgroundView = selView;
        
        creditImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
        creditImgView.tag = 40;
        [[cell contentView] addSubview:creditImgView];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 5.0, 0.0, 0.0)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:17.0];
        nameLabel.tag = 41;
        [[cell contentView] addSubview:nameLabel];
        
        locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 5.0, 0.0, 0.0)];
        locationLabel.backgroundColor = [UIColor clearColor];
        locationLabel.textColor = [UIColor grayColor];
        locationLabel.font = [UIFont fontNamedLoRes15BoldOaklandWithSize:15.0];
        locationLabel.tag = 42;
        [[cell contentView] addSubview:locationLabel];
    }
    
    if ( !creditImgView ) creditImgView = (UIImageView *)[[cell contentView] viewWithTag:40];
    if ( !nameLabel ) nameLabel = (UILabel *)[[cell contentView] viewWithTag:41];
    if ( !locationLabel ) locationLabel = (UILabel *)[[cell contentView] viewWithTag:42];
    
        
    if ( [[_dataArray objectAtIndex:indexPath.row] isKindOfClass:[NSString class]] && [[_dataArray objectAtIndex:indexPath.row] isEqualToString:@"credit"] ) {
        [creditImgView setImage:[UIImage imageNamed:@"foursquare"]];
        nameLabel.text = nil;
        locationLabel.text = nil;
        cell.userInteractionEnabled = NO;
    }
    else if ( [[_dataArray objectAtIndex:indexPath.row] isKindOfClass:[NSString class]] && [[_dataArray objectAtIndex:indexPath.row] isEqualToString:@"searching"] ) {
        [creditImgView setImage:nil];
        nameLabel.frame = CGRectMake(15.0, 18.0, 0.0, 0.0);
        nameLabel.text = @"Searching nearby...";
        nameLabel.textColor = [UIColor grayColor];
        [nameLabel sizeToFit];
        
        locationLabel.text = nil;
        
        cell.userInteractionEnabled = NO;
    }
    else {
        [creditImgView setImage:nil];
        NSDictionary *venueDict = [_dataArray objectAtIndex:indexPath.row];
        
        nameLabel.frame = CGRectMake(15.0, 8.0, cell.frame.size.width - 30.0, 0.0);
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.text = [venueDict objectForKey:@"venueName"];
        CGRect frame = nameLabel.frame;
        [nameLabel sizeToFit];
        frame.size.height = nameLabel.frame.size.height;
        nameLabel.frame = frame;
        
        locationLabel.frame = CGRectMake(15.0, 28.0, cell.frame.size.width - 30.0, 0.0);
        locationLabel.text = [venueDict objectForKey:@"venueLocation"];
        [locationLabel sizeToFit];

        cell.userInteractionEnabled = YES;
    }
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *venueInfo = [_dataArray objectAtIndex:indexPath.row];
    
    NSArray *vcs = [NSArray arrayWithArray:self.navigationController.viewControllers];
    CheckInViewController *checkinVC = [vcs objectAtIndex:0];
    checkinVC.venueData = venueInfo;
    
    ///NSLog(@"venue data = %@", venueInfo);
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

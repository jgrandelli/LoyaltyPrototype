//
//  ProfileGraduateViewController.m
//  LoyaltyPrototype
//
//  Created by Jason Grandelli on 1/17/13.
//  Copyright (c) 2013 URBN. All rights reserved.
//

#import "ProfileGraduateViewController.h"
#import "BackgroundView.h"
#import "UIFont+UrbanAdditions.h"
#import "NavBarItemsViewController.h"
#import "UserData.h"
#import <AFNetworking.h>
#import <MBProgressHUD.h>
#import <QuartzCore/QuartzCore.h>

@interface ProfileGraduateViewController ()

@property (nonatomic, strong) ChallengeData *data;
@property (nonatomic, strong) UIView *compBar;
@property (nonatomic, strong) UIView *compBarBack;
@property (nonatomic, strong) UILabel *compBarLabel;

@property (nonatomic, strong) UIButton *collegeYesBtn;
@property (nonatomic, strong) UIButton *collegeNoBtn;

@property (nonatomic, strong) UILabel *monthLabel;
@property (nonatomic, strong) UILabel *yearLabel;
@property (nonatomic, strong) UIView *pickerHolder;

@property (nonatomic, strong) UILabel *schoolLabel;

@property (nonatomic, strong) UIButton *dormBtn;
@property (nonatomic, strong) UIButton *offCampusBtn;
@property (nonatomic, strong) UIButton *parentsBtn;
@property (nonatomic, strong) UIButton *otherBtn;

@property (nonatomic, strong) NSArray *monthArray;
@property (nonatomic, strong) NSArray *yearArray;
@property (nonatomic, strong) NSArray *schoolArray;

@property (nonatomic, strong) NSString *dropDownType;

@property (nonatomic, strong) NSMutableArray *tallyArray;

@end

@implementation ProfileGraduateViewController

#define MARGIN 15.0f
#define PADDING 10.0f
#define BASE_URL @"https://sandbox.bunchball.net/nitro/json?value=0&asyncToken=&method=user%2ElogAction&metadata=&competitionInstanceId=&newsfeed=&target=&userId=16&storeResponse=false&tags="

- (id)initWithData:(ChallengeData *)data {
	self = [super init];
	
	if (nil != self) {
        self.data = data;
	}
	
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    self.monthArray = @[@"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December"];
    self.yearArray = @[@"2013", @"2014", @"2015", @"2016", @"2017", @"2018"];
    self.schoolArray = @[@"Temple University", @"University of Pennsylvania", @"Drexel University", @"Villanova University", @"Cabrini College", @"Widener University"];
    self.tallyArray = [[NSMutableArray alloc] initWithObjects:@0.0, @0.0, @0.0, @0.0, nil];
    
    
    [self.navigationItem setHidesBackButton:YES];

    int i = (arc4random() % 9) + 1;
    NSString *patternName = [NSString stringWithFormat:@"Background%i", i];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:patternName]];
    
    CGFloat totalWidth = self.view.frame.size.width - MARGIN*2;
    
    UIScrollView *scroller = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    
    BackgroundView *backView = [[BackgroundView alloc] initWithFrame:CGRectMake(MARGIN, self.navigationController.navigationBar.frame.size.height + MARGIN, totalWidth, 100.0)];
    [scroller addSubview:backView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, PADDING, 0.0, 0.0)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:16.0];
    titleLabel.text = _data.title;
    [titleLabel sizeToFit];
    [backView addSubview:titleLabel];
    
    self.compBarLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x + 5.0,
                                                               titleLabel.frame.origin.y + titleLabel.frame.size.height + 15.0,
                                                               0.0,
                                                               0.0)];
    _compBarLabel.backgroundColor = [UIColor clearColor];
    _compBarLabel.textColor = [UIColor whiteColor];
    _compBarLabel.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:13.0];
    int perc = _data.completion * 100;
    _compBarLabel.text = [NSString stringWithFormat:@"%i%% completed", perc];
    [_compBarLabel sizeToFit];
    [backView addSubview:_compBarLabel];
    
    self.compBar = [[UIView alloc] initWithFrame:CGRectMake(_compBarLabel.frame.origin.x - 5.0,
                                                            _compBarLabel.frame.origin.y - 5.0,
                                                            (totalWidth - PADDING*2 - 5.0) * _data.completion,
                                                            _compBarLabel.frame.size.height + 10.0)];
    _compBar.backgroundColor = [UIColor redColor];
    [backView insertSubview:_compBar belowSubview:_compBarLabel];
    
    self.compBarBack = [[UIView alloc] initWithFrame:CGRectMake(_compBar.frame.origin.x,
                                                                _compBar.frame.origin.y,
                                                                totalWidth - PADDING*2 - 5.0,
                                                                _compBar.frame.size.height)];
    _compBarBack.backgroundColor = [UIColor darkGrayColor];
    [backView insertSubview:_compBarBack belowSubview:_compBar];
    
    backView.frame = CGRectMake(MARGIN, self.navigationController.navigationBar.frame.size.height + MARGIN, totalWidth, _compBarBack.frame.origin.y + _compBarBack.frame.size.height + PADDING + 5.0);
    [backView setNeedsDisplay];
    
    CGFloat yPos = backView.frame.size.height + backView.frame.origin.y + 10.0;
    
    backView = [[BackgroundView alloc] initWithFrame:CGRectMake(MARGIN, yPos, totalWidth, 100.0)];
    [scroller addSubview:backView];
    
    UILabel *studentLabel = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, PADDING, 0.0, 0.0)];
    studentLabel.backgroundColor = [UIColor clearColor];
    studentLabel.textColor = [UIColor blackColor];
    studentLabel.font = [UIFont fontNamedLoRes15BoldOaklandWithSize:16.0];
    studentLabel.text = @"Are you a college student?";
    [studentLabel sizeToFit];
    [backView addSubview:studentLabel];
    
    UIImage *radio = [UIImage imageNamed:@"radioBtn"];
    UIImage *radioSelected = [UIImage imageNamed:@"radioBtn-selected"];
    
    self.collegeYesBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _collegeYesBtn.frame = CGRectMake(PADDING, studentLabel.frame.origin.y + studentLabel.frame.size.height + 8.0, 30.0, 30.0);
    _collegeYesBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_collegeYesBtn setImage:radio forState:UIControlStateNormal];
    [_collegeYesBtn setImage:radioSelected forState:UIControlStateSelected];
    _collegeYesBtn.tag = 10;
    [_collegeYesBtn addTarget:self action:@selector(collegeRadioSelected:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:_collegeYesBtn];
    
    UILabel *yesLabel = [[UILabel alloc] initWithFrame:CGRectMake(38.0, 5.0, 0.0, 0.0)];
    yesLabel.backgroundColor = [UIColor clearColor];
    yesLabel.textColor = [UIColor blackColor];
    yesLabel.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:16.0];
    yesLabel.text = @"Yes";
    yesLabel.tag = 11;
    [yesLabel sizeToFit];
    [_collegeYesBtn addSubview:yesLabel];
    
    CGRect frame = _collegeYesBtn.frame;
    frame.size.width = yesLabel.frame.origin.x + yesLabel.frame.size.width;
    _collegeYesBtn.frame = frame;
    
    self.collegeNoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _collegeNoBtn.frame = CGRectMake(38.0 + PADDING + yesLabel.frame.size.width + 25.0, studentLabel.frame.origin.y + studentLabel.frame.size.height + 8.0, 30.0, 30.0);
    _collegeNoBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_collegeNoBtn setImage:radio forState:UIControlStateNormal];
    [_collegeNoBtn setImage:radioSelected forState:UIControlStateSelected];
    _collegeNoBtn.tag = 20;
    [_collegeNoBtn addTarget:self action:@selector(collegeRadioSelected:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:_collegeNoBtn];

    UILabel *noLabel = [[UILabel alloc] initWithFrame:CGRectMake(38.0, 5.0, 0.0, 0.0)];
    noLabel.backgroundColor = [UIColor clearColor];
    noLabel.textColor = [UIColor blackColor];
    noLabel.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:16.0];
    noLabel.text = @"No";
    noLabel.tag = 21;
    [noLabel sizeToFit];
    [_collegeNoBtn addSubview:noLabel];

    frame = _collegeNoBtn.frame;
    frame.size.width = noLabel.frame.origin.x + noLabel.frame.size.width;
    _collegeNoBtn.frame = frame;

    frame = backView.frame;
    frame.size.height = _collegeYesBtn.frame.origin.y + _collegeYesBtn.frame.size.height + PADDING + 5.0;
    backView.frame = frame;
    [backView setNeedsDisplay];
    
    yPos = backView.frame.origin.y + backView.frame.size.height + 10.0;
    
    backView = [[BackgroundView alloc] initWithFrame:CGRectMake(MARGIN, yPos, totalWidth, 100.0)];
    [scroller addSubview:backView];
    
    UILabel *gradDate = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, PADDING, 0.0, 0.0)];
    gradDate.backgroundColor = [UIColor clearColor];
    gradDate.textColor = [UIColor blackColor];
    gradDate.font = [UIFont fontNamedLoRes15BoldOaklandWithSize:16.0];
    gradDate.text = @"What's your expected graduation date?";
    [gradDate sizeToFit];
    [backView addSubview:gradDate];
    
    UIImage *dropDownImg = [UIImage imageNamed:@"dropDownBGResizable"];
    UIEdgeInsets insets = UIEdgeInsetsMake(5.0, 5.0, 5.0, 34.0);
    dropDownImg = [dropDownImg resizableImageWithCapInsets:insets];
    
    UIButton *monthBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    monthBtn.frame = CGRectMake(PADDING, gradDate.frame.origin.y + gradDate.frame.size.height + 8.0, 140.0, 30.0);
    monthBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    [monthBtn setImage:dropDownImg forState:UIControlStateNormal];
    monthBtn.tag = 100;
    [monthBtn addTarget:self action:@selector(dropDownSelected:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:monthBtn];
    
    self.monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(monthBtn.frame.origin.x + 8.0, monthBtn.frame.origin.y + 5.0, 0.0, 0.0)];
    _monthLabel.backgroundColor = [UIColor clearColor];
    _monthLabel.textColor = [UIColor blackColor];
    _monthLabel.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:16.0];
    _monthLabel.text = @"Month";
    [_monthLabel sizeToFit];
    [backView addSubview:_monthLabel];


    UIButton *yearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    yearBtn.frame = CGRectMake(monthBtn.frame.origin.x + monthBtn.frame.size.width + 20.0, monthBtn.frame.origin.y, 100.0, 30.0);
    yearBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    [yearBtn setImage:dropDownImg forState:UIControlStateNormal];
    yearBtn.tag = 101;
    [yearBtn addTarget:self action:@selector(dropDownSelected:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:yearBtn];
    
    self.yearLabel = [[UILabel alloc] initWithFrame:CGRectMake(yearBtn.frame.origin.x + 8.0, yearBtn.frame.origin.y + 5.0, 0.0, 0.0)];
    _yearLabel.backgroundColor = [UIColor clearColor];
    _yearLabel.textColor = [UIColor blackColor];
    _yearLabel.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:16.0];
    _yearLabel.text = @"Year";
    [_yearLabel sizeToFit];
    [backView addSubview:_yearLabel];
    
    frame = backView.frame;
    frame.size.height = monthBtn.frame.origin.y + monthBtn.frame.size.height + PADDING + 5.0;
    backView.frame = frame;
    [backView setNeedsDisplay];
    
    yPos = backView.frame.origin.y + backView.frame.size.height + 10.0;
    
    backView = [[BackgroundView alloc] initWithFrame:CGRectMake(MARGIN, yPos, totalWidth, frame.size.height)];
    [scroller addSubview:backView];
    

    UILabel *school = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, PADDING, 0.0, 0.0)];
    school.backgroundColor = [UIColor clearColor];
    school.textColor = [UIColor blackColor];
    school.font = [UIFont fontNamedLoRes15BoldOaklandWithSize:16.0];
    school.text = @"What school do you go to?";
    [school sizeToFit];
    [backView addSubview:school];
    
    UIButton *schoolBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    schoolBtn.frame = CGRectMake(PADDING, school.frame.origin.y + school.frame.size.height + 8.0, backView.frame.size.width - PADDING*2 - 5.0, 30.0);
    schoolBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    [schoolBtn setImage:dropDownImg forState:UIControlStateNormal];
    schoolBtn.tag = 102;
    [schoolBtn addTarget:self action:@selector(dropDownSelected:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:schoolBtn];

    self.schoolLabel = [[UILabel alloc] initWithFrame:CGRectMake(schoolBtn.frame.origin.x + 8.0, schoolBtn.frame.origin.y + 5.0, 0.0, 0.0)];
    _schoolLabel.backgroundColor = [UIColor clearColor];
    _schoolLabel.textColor = [UIColor blackColor];
    _schoolLabel.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:16.0];
    _schoolLabel.text = @"Choose One";
    [_schoolLabel sizeToFit];
    [backView addSubview:_schoolLabel];
    
    yPos = backView.frame.origin.y + backView.frame.size.height + 10.0;
    
    backView = [[BackgroundView alloc] initWithFrame:CGRectMake(MARGIN, yPos, totalWidth, 300.0)];
    [scroller addSubview:backView];
    
    UILabel *housingLabel = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, PADDING, 0.0, 0.0)];
    housingLabel.backgroundColor = [UIColor clearColor];
    housingLabel.textColor = [UIColor blackColor];
    housingLabel.font = [UIFont fontNamedLoRes15BoldOaklandWithSize:16.0];
    housingLabel.text = @"Where do you live at school?";
    [housingLabel sizeToFit];
    [backView addSubview:housingLabel];
    
    self.dormBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _dormBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_dormBtn setImage:radio forState:UIControlStateNormal];
    [_dormBtn setImage:radioSelected forState:UIControlStateSelected];
    _dormBtn.tag = 40;
    [_dormBtn addTarget:self action:@selector(housingRadioBtnSelected:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:_dormBtn];
    
    UILabel *dormLabel = [[UILabel alloc] initWithFrame:CGRectMake(38.0, 5.0, 0.0, 0.0)];
    dormLabel.backgroundColor = [UIColor clearColor];
    dormLabel.textColor = [UIColor blackColor];
    dormLabel.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:16.0];
    dormLabel.text = @"Dorm";
    dormLabel.tag = 41;
    [dormLabel sizeToFit];
    [_dormBtn addSubview:dormLabel];
    _dormBtn.frame = CGRectMake(PADDING, housingLabel.frame.origin.y + housingLabel.frame.size.height + 8.0, dormLabel.frame.origin.x + dormLabel.frame.size.width, 30.0);
    
    self.offCampusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _offCampusBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_offCampusBtn setImage:radio forState:UIControlStateNormal];
    [_offCampusBtn setImage:radioSelected forState:UIControlStateSelected];
    _offCampusBtn.tag = 50;
    [_offCampusBtn addTarget:self action:@selector(housingRadioBtnSelected:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:_offCampusBtn];
    
    UILabel *offCampusLabel = [[UILabel alloc] initWithFrame:CGRectMake(38.0, 0.0, backView.frame.size.width - PADDING*2 - 43.0, 0.0)];
    offCampusLabel.backgroundColor = [UIColor clearColor];
    offCampusLabel.textColor = [UIColor blackColor];
    offCampusLabel.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:16.0];
    offCampusLabel.lineBreakMode = NSLineBreakByWordWrapping;
    offCampusLabel.numberOfLines = 0;
    offCampusLabel.text = @"Off Campus (House/Apartment)";
    offCampusLabel.tag = 51;
    frame = offCampusLabel.frame;
    [offCampusLabel sizeToFit];
    frame.size.height = offCampusLabel.frame.size.height;
    offCampusLabel.frame = frame;
    [_offCampusBtn addSubview:offCampusLabel];
    _offCampusBtn.frame = CGRectMake(PADDING, _dormBtn.frame.origin.y + _dormBtn.frame.size.height + 10.0, offCampusLabel.frame.origin.x + offCampusLabel.frame.size.width, offCampusLabel.frame.size.height);

    self.parentsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _parentsBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_parentsBtn setImage:radio forState:UIControlStateNormal];
    [_parentsBtn setImage:radioSelected forState:UIControlStateSelected];
    _parentsBtn.tag = 60;
    [_parentsBtn addTarget:self action:@selector(housingRadioBtnSelected:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:_parentsBtn];

    UILabel *parentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(38.0, 5.0, backView.frame.size.width - PADDING*2 - 43.0, 0.0)];
    parentsLabel.backgroundColor = [UIColor clearColor];
    parentsLabel.textColor = [UIColor blackColor];
    parentsLabel.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:16.0];
    parentsLabel.lineBreakMode = NSLineBreakByWordWrapping;
    parentsLabel.numberOfLines = 0;
    parentsLabel.text = @"With my parents";
    parentsLabel.tag = 61;
    [parentsLabel sizeToFit];
    [_parentsBtn addSubview:parentsLabel];
    _parentsBtn.frame = CGRectMake(PADDING, _offCampusBtn.frame.origin.y + _offCampusBtn.frame.size.height + 10.0, parentsLabel.frame.origin.x + parentsLabel.frame.size.width, MAX(parentsLabel.frame.size.height, 30.0));

    self.otherBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _otherBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_otherBtn setImage:radio forState:UIControlStateNormal];
    [_otherBtn setImage:radioSelected forState:UIControlStateSelected];
    _otherBtn.tag = 70;
    [_otherBtn addTarget:self action:@selector(housingRadioBtnSelected:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:_otherBtn];
    
    UILabel *otherLabel = [[UILabel alloc] initWithFrame:CGRectMake(38.0, 5.0, backView.frame.size.width - PADDING*2 - 43.0, 0.0)];
    otherLabel.backgroundColor = [UIColor clearColor];
    otherLabel.textColor = [UIColor blackColor];
    otherLabel.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:16.0];
    otherLabel.lineBreakMode = NSLineBreakByWordWrapping;
    otherLabel.numberOfLines = 0;
    otherLabel.text = @"Other";
    otherLabel.tag = 71;
    [otherLabel sizeToFit];
    [_otherBtn addSubview:otherLabel];
    _otherBtn.frame = CGRectMake(PADDING, _parentsBtn.frame.origin.y + _parentsBtn.frame.size.height + 10.0, otherLabel.frame.origin.x + otherLabel.frame.size.width, MAX(otherLabel.frame.size.height, 30.0));
    
    frame = backView.frame;
    frame.size.height = _otherBtn.frame.size.height + _otherBtn.frame.origin.y + PADDING + 5.0;
    backView.frame = frame;
    [backView setNeedsDisplay];

    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    submitBtn.frame = CGRectMake(MARGIN, frame.origin.y + frame.size.height + 10.0, totalWidth, 44.0);
    backView = [[BackgroundView alloc] initWithFrame:CGRectMake(0, 0, totalWidth, 44.0)];
    backView.userInteractionEnabled = NO;
    [submitBtn addSubview:backView];
    UILabel *submitLabel = [[UILabel alloc] initWithFrame:CGRectMake(3.0, 3.0, backView.frame.size.width - 11.0, backView.frame.size.height -11.0)];
    submitLabel.backgroundColor = [UIColor blueColor];
    submitLabel.textColor = [UIColor whiteColor];
    submitLabel.font = [UIFont fontNamedLoRes12BoldOaklandWithSize:18.0];
    submitLabel.textAlignment = NSTextAlignmentCenter;
    submitLabel.text = @"SUBMIT!";
    [submitBtn addSubview:submitLabel];
    [submitBtn addTarget:self action:@selector(submitInfo) forControlEvents:UIControlEventTouchUpInside];
    
    [scroller addSubview:submitBtn];
    
    scroller.contentSize = CGSizeMake(scroller.frame.size.width, submitBtn.frame.origin.y + submitBtn.frame.size.height + MARGIN + 5.0);
    [self.view addSubview:scroller];
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
}

- (void)updateTally {
    CGFloat compPerc = 0.0;
    for ( int i = 0; i < [_tallyArray count]; ++i ) {
        compPerc += [[_tallyArray objectAtIndex:i] floatValue];
    }

    int perc = compPerc * 100;
    _compBarLabel.text = [NSString stringWithFormat:@"%i%% completed", perc];
    [_compBarLabel sizeToFit];
    
    [UIView animateWithDuration:.4
                          delay:0.0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                         CGRect frame = _compBar.frame;
                         frame.size.width = _compBarBack.frame.size.width * compPerc;
                         _compBar.frame = frame;
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (void)backBtnPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)submitInfo {
    NSArray *varArray = @[@"graduate%5Fin%5Fcollege", @"graduate%5Fgrad%5Fdate", @"graduate%5Fmy%5Fschool", @"graduate%5Fhousing"];

    NSMutableArray *opArray = [[NSMutableArray alloc] init];
    for ( int i = 0; i < [_tallyArray count]; ++i ) {
        if ( [[_tallyArray objectAtIndex:i] floatValue] == 0.25 ) {
            NSString *urlString = [NSString stringWithFormat:@"%@%@&sessionKey=%@", BASE_URL, [varArray objectAtIndex:i], [[UserData sharedInstance] sessionKey]];
            NSURL *url = [NSURL URLWithString:urlString];
            NSURLRequest *req = [NSURLRequest requestWithURL:url];
            AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:req
                                                                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                         }
                                                                                         failure:nil];
            
            [opArray addObject:op];
        }
    }



    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    [client enqueueBatchOfHTTPRequestOperations:opArray
                                  progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
                                      nil;
                                  }
                                completionBlock:^(NSArray *operations) {
                                }];
}

- (void)collegeRadioSelected:(id)sender {
    if ( [sender tag] == 10 ) {
        _collegeYesBtn.selected = YES;
        
        UILabel *label = (UILabel *)[_collegeYesBtn viewWithTag:11];
        label.textColor = [UIColor blueColor];
        
        _collegeNoBtn.selected = NO;
        label = (UILabel *)[_collegeNoBtn viewWithTag:21];
        label.textColor = [UIColor blackColor];
    }
    else {
        _collegeYesBtn.selected = NO;
        UILabel *label = (UILabel *)[_collegeYesBtn viewWithTag:11];
        label.textColor = [UIColor blackColor];
        
        _collegeNoBtn.selected = YES;
        label = (UILabel *)[_collegeNoBtn viewWithTag:21];
        label.textColor = [UIColor blueColor];
    }
    
    [_tallyArray replaceObjectAtIndex:0 withObject:@.25];
    [self updateTally];
}

- (void)housingRadioBtnSelected:(id)sender {
    for ( int i = 4; i < 8; ++i ) {
        UIButton *btn = (UIButton *)[self.view viewWithTag:i*10];
        UILabel *label = (UILabel *)[self.view viewWithTag:(i*10 + 1)];
        if ( i*10 == [sender tag] ) {
            btn.selected = YES;
            label.textColor = [UIColor blueColor];
        }
        else {
            btn.selected = NO;
            label.textColor = [UIColor blackColor];
        }
    }

    [_tallyArray replaceObjectAtIndex:3 withObject:@.25];
    [self updateTally];
}

- (void)dropDownSelected:(id)sender {
    UIPickerView *picker = nil;
    UIButton *goBtn = nil;
    UIButton *cancelBtn = nil;
    
    if ( [sender tag] == 100 || [sender tag] == 101 ) self.dropDownType = @"date";
    else self.dropDownType = @"school";
    
    if ( !self.pickerHolder ) {
        self.pickerHolder = [[UIView alloc] init];

        UIButton *catcher = [UIButton buttonWithType:UIButtonTypeCustom];
        catcher.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
        [catcher addTarget:self action:@selector(cancelDropdownTouched:) forControlEvents:UIControlEventTouchUpInside];
        [_pickerHolder addSubview:catcher];
        
        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 240.0, self.view.frame.size.width, 240.0)];
        background.backgroundColor = [UIColor blackColor];
        [_pickerHolder addSubview:background];
        
        picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, background.frame.origin.y + 40.0, [UIScreen mainScreen].bounds.size.width, 200.0)];
        picker.tag = 30;
        picker.showsSelectionIndicator = YES;
        [_pickerHolder addSubview:picker];
        
        UIImage *selectImg = [UIImage imageNamed:@"selectBtn"];
        goBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [goBtn setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - selectImg.size.width - 5.0, background.frame.origin.y + 6.0, selectImg.size.width, selectImg.size.height)];
        [goBtn setImage:selectImg forState:UIControlStateNormal];
        [goBtn addTarget:self action:@selector(selectTouched:) forControlEvents:UIControlEventTouchUpInside];
        [_pickerHolder addSubview:goBtn];
        
        UIImage *cancelImg = [UIImage imageNamed:@"cancelBtn"];
        cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelBtn setFrame:CGRectMake(5.0, background.frame.origin.y + 6.0, cancelImg.size.width, cancelImg.size.height)];
        [cancelBtn setImage:cancelImg forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancelDropdownTouched:) forControlEvents:UIControlEventTouchUpInside];
        [_pickerHolder addSubview:cancelBtn];
    }
    
    if ( !picker ) picker = (UIPickerView *)[_pickerHolder viewWithTag:30];
    picker.dataSource = self;
    picker.delegate = self;
    picker.showsSelectionIndicator = YES;
    
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
}

- (void)cancelDropdownTouched:(id)sender {
    [self animateOutPickerHolder];
}

- (void)selectTouched:(id)sender {
    UIPickerView *picker = (UIPickerView *)[_pickerHolder viewWithTag:30];
    
    
    if ( [_dropDownType isEqualToString:@"date"] ) {
        int monthInd = [picker selectedRowInComponent:0];
        int yearInd = [picker selectedRowInComponent:1];
        
        _monthLabel.text = [_monthArray objectAtIndex:monthInd];
        [_monthLabel sizeToFit];
        
        _yearLabel.text = [_yearArray objectAtIndex:yearInd];
        [_yearLabel sizeToFit];
        

        [_tallyArray replaceObjectAtIndex:1 withObject:@.25];
        [self updateTally];
    }
    else {
        int schoolInd = [picker selectedRowInComponent:0];
        
        _schoolLabel.text = [_schoolArray objectAtIndex:schoolInd];
        [_schoolLabel sizeToFit];

        [_tallyArray replaceObjectAtIndex:2 withObject:@.25];
        [self updateTally];
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


#pragma mark - UIPickerViewDataSource methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    if ( [_dropDownType isEqualToString:@"date"] ) return 2;
    else return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSArray *arr = nil;
    
    if ( [_dropDownType isEqualToString:@"date"] ) {
        if ( component == 0 ) arr = _monthArray;
        else  arr = _yearArray;
    }
    else arr = _schoolArray;
    
    return [arr count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSArray *arr = nil;
    
    if ( [_dropDownType isEqualToString:@"date"] ) {
        if ( component == 0 ) arr = _monthArray;
        else  arr = _yearArray;
    }
    else arr = _schoolArray;

    return [arr objectAtIndex:row];
}

#pragma mark - UIPickerViewDelegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

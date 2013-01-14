//
//  ChallengeDetailViewController.m
//  LoyaltyPrototype
//
//  Created by Jason Grandelli on 1/2/13.
//  Copyright (c) 2013 URBN. All rights reserved.
//

#import "ChallengeDetailViewController.h"
#import "UIColor+ColorConstants.h"

@interface ChallengeDetailViewController ()

@property (nonatomic, strong) ChallengeData *challengeData;

@end

@implementation ChallengeDetailViewController

#define MARGIN 15.0f

- (id)initWithData:(ChallengeData *)data {
	self = [super init];
	
	if (nil != self) {
        self.challengeData = data;
	}
	
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    /*
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"🔁" style:UIBarButtonItemStylePlain target:self action:@selector(refreshData)];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                    [UIFont fontWithName:@"Entypo" size:45.0], UITextAttributeFont,
                                                                    [UIColor neonGreen], UITextAttributeTextColor, nil] forState:UIControlStateNormal];
    */
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,
                                                                              self.navigationController.navigationBar.frame.size.height,
                                                                              self.view.frame.size.width,
                                                                              self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height)];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN, MARGIN, self.view.frame.size.width - (MARGIN * 2), 0.0)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor offWhite];
    titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    titleLabel.numberOfLines = 0;
    titleLabel.text = _challengeData.title;
    [titleLabel sizeToFit];
    [scrollView addSubview:titleLabel];
    
    UILabel *pointsLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN,
                                                                     titleLabel.frame.size.height + titleLabel.frame.origin.y,
                                                                     self.view.frame.size.width - (MARGIN * 2),
                                                                     0.0)];
    pointsLabel.backgroundColor = [UIColor clearColor];
    pointsLabel.textColor = [UIColor neonGreen];
    pointsLabel.font = [UIFont italicSystemFontOfSize:16.0];
    pointsLabel.text = [NSString stringWithFormat:@"%@ points", _challengeData.pointsString];
    [pointsLabel sizeToFit];
    [scrollView addSubview:pointsLabel];
    
    UILabel *completionLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN + 5.0,
                                                                        pointsLabel.frame.origin.y + pointsLabel.frame.size.height + 10.0,
                                                                        self.view.frame.size.width - (MARGIN * 2),
                                                                        10.0)];
    completionLabel.backgroundColor = [UIColor clearColor];
    completionLabel.textColor = [UIColor offWhite];
    completionLabel.font = [UIFont systemFontOfSize:14.0];
    int perc = _challengeData.completion * 100;
    completionLabel.text = [NSString stringWithFormat:@"%i%% completed", perc];
    [completionLabel sizeToFit];
    [scrollView addSubview:completionLabel];

    CGFloat totalWidth = self.view.frame.size.width - (MARGIN * 2.0);
    
    UIView *completeMeterDone = [[UIView alloc] initWithFrame:CGRectMake(completionLabel.frame.origin.x - 5.0,
                                                                         completionLabel.frame.origin.y - 5.0,
                                                                         totalWidth * _challengeData.completion,
                                                                         completionLabel.frame.size.height + 10.0)];
    completeMeterDone.backgroundColor = [UIColor neonBlue];
    completeMeterDone.alpha = 0.5;
    [scrollView insertSubview:completeMeterDone belowSubview:completionLabel];
    
    UIView *completeMeterBack = [[UIView alloc] initWithFrame:CGRectMake(completeMeterDone.frame.origin.x + completeMeterDone.frame.size.width,
                                                                         completionLabel.frame.origin.y - 5.0,
                                                                         totalWidth * (1 - _challengeData.completion),
                                                                         completionLabel.frame.size.height + 10.0)];
    completeMeterBack.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    [scrollView insertSubview:completeMeterBack belowSubview:completionLabel];
    
    
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN,
                                                                          completeMeterDone.frame.origin.y + completeMeterDone.frame.size.height + 10.0,
                                                                          totalWidth, 0.0)];
    descriptionLabel.backgroundColor = [UIColor clearColor];
    descriptionLabel.textColor = [UIColor offWhite];
    descriptionLabel.font = [UIFont systemFontOfSize:12.0];
    descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.text = _challengeData.description;
    [descriptionLabel sizeToFit];
    [scrollView addSubview:descriptionLabel];
    
    UILabel *rulesLabel = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN, descriptionLabel.frame.origin.y + descriptionLabel.frame.size.height + 15.0, 0.0, 0.0)];
    rulesLabel.backgroundColor = [UIColor clearColor];
    rulesLabel.textColor = [UIColor neonGreen];
    rulesLabel.font = [UIFont boldSystemFontOfSize:14.0];
    rulesLabel.text = @"Rules:";
    [rulesLabel sizeToFit];
    [scrollView addSubview:rulesLabel];

    UIView *greenLine = [[UIView alloc] initWithFrame:CGRectMake(15.0, rulesLabel.frame.origin.y + rulesLabel.frame.size.height, totalWidth, 1.0)];
    greenLine.backgroundColor = [UIColor neonGreen];
    greenLine.alpha = 0.3;
    [scrollView addSubview:greenLine];
    
    CGFloat yPos = greenLine.frame.origin.y + 5.0;
    CGFloat xPos = 50.0;
    for ( NSDictionary *rule in _challengeData.rulesArray ) {
        UILabel *ruleCompletion = [[UILabel alloc] initWithFrame:CGRectMake(MARGIN, yPos, 0.0, 0.0)];
        ruleCompletion.backgroundColor = [UIColor clearColor];
        ruleCompletion.textColor = [UIColor neonGreen];
        ruleCompletion.font = [UIFont boldSystemFontOfSize:12.0];
        int goal = [[rule objectForKey:@"goal"] intValue];
        int achieved = [[rule objectForKey:@"achieved"] intValue];
        ruleCompletion.text = [NSString stringWithFormat:@"%i/%i", achieved, goal];
        [ruleCompletion sizeToFit];
        [scrollView addSubview:ruleCompletion];
        
        UILabel *ruleDescLabel = [[UILabel alloc] initWithFrame:CGRectMake(xPos, yPos, totalWidth - xPos, 0.0)];
        ruleDescLabel.backgroundColor = [UIColor clearColor];
        ruleDescLabel.textColor = [UIColor offWhite];
        ruleDescLabel.font = [UIFont systemFontOfSize:12.0];
        ruleDescLabel.lineBreakMode = NSLineBreakByWordWrapping;
        ruleDescLabel.numberOfLines = 0;
        ruleDescLabel.text = [rule objectForKey:@"description"];
        [ruleDescLabel sizeToFit];
        [scrollView addSubview:ruleDescLabel];
        
        yPos = ruleDescLabel.frame.size.height + yPos + 5.0;
    }
    
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width, yPos + MARGIN);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

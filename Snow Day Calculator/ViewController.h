//
//  ViewController.h
//  Snow Day Calculator
//
//  Created by Daniel Katz on 2/7/16.
//  Copyright © 2016 Stratton Design. All rights reserved.
//
#import "Reachability.h"
#import "MBCircularProgressBarView.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "GAITrackedViewController.h"
@import GoogleMobileAds;
#import <UIKit/UIKit.h>
#import "YRActivityIndicator.h"
#import "BFPaperButton.h"
#import "UIColor+BFPaperColors.h"
@interface ViewController : GAITrackedViewController <UITableViewDataSource,UITableViewDelegate,GADBannerViewDelegate>{
    Reachability *internetReachableFoo;
    int Score;
    NSString *DayOfWeek;
    NSString *Month;
    int NumberOfSnowdays;
    int Temp;
    int WindSpeed;
    int InchesOfSnow;
    BOOL SnowStormWarning;
    YRActivityIndicator *loader;
    NSString *cityUrl;
    int indextopull;
    NSString *prediction;
}
-(void) checkNetworkStatus:(NSNotification *)notice;
@property (weak, nonatomic) IBOutlet MBCircularProgressBarView *progressView;
@property (weak, nonatomic) IBOutlet GADBannerView *adBannerView2;
@property (weak, nonatomic) IBOutlet UIImageView *materialImageView;
@property (weak, nonatomic) IBOutlet UIView *tempView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *percentLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet BFPaperButton *shareButton;


@end


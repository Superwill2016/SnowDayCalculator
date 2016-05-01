//
//  startViewController.h
//  Snow Day Calculator
//
//  Created by Daniel Katz on 2/8/16.
//  Copyright © 2016 Stratton Design. All rights reserved.
//

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "GAITrackedViewController.h"
@import GoogleMobileAds;
#import <UIKit/UIKit.h>
#import "BFPaperButton.h"
#import "UIColor+BFPaperColors.h"
#import "JTMaterialTransition.h"
#import <iAd/iAd.h>
@interface startViewController : GAITrackedViewController <UIViewControllerTransitioningDelegate, ADBannerViewDelegate,GADBannerViewDelegate>
@property (weak, nonatomic) IBOutlet BFPaperButton *calculateButton;
@property (nonatomic) JTMaterialTransition *transition;
@property (weak, nonatomic) IBOutlet UITextField *snowDayTF;
@property (weak, nonatomic) IBOutlet UITextField *ZipCodeTF;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConsraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@property (weak, nonatomic) IBOutlet GADBannerView *adBannerView;

@end

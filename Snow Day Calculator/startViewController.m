//
//  startViewController.m
//  Snow Day Calculator
//
//  Created by Daniel Katz on 2/8/16.
//  Copyright © 2016 Stratton Design. All rights reserved.
//
#import "startViewController.h"
#import "ViewController.h"
#import "UIViewController+MaterialDesign.h"
@interface startViewController ()

@end

@implementation startViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.screenName = @"EnterInfoScreen";
    NSLog(@"Google Mobile Ads SDK version: %@", [GADRequest sdkVersion]);
    
    // Replace this ad unit ID with your own ad unit ID.
    self.adBannerView.adUnitID = @"ca-app-pub-2350587744441133/5769730805";
    self.adBannerView.rootViewController = self;
    self.adBannerView.delegate = self;
    
    GADRequest *request = [GADRequest request];
    // Requests test ads on devices you specify. Your test device ID is printed to the console when
    // an ad request is made. GADBannerView automatically returns test ads when running on a
    // simulator.
    request.testDevices = @[ kGADSimulatorID ];
    [self.adBannerView loadRequest:request];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:63/255.0 green:81/255.0 blue:181/255.0 alpha:1.0f]];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.layer.masksToBounds = false;
    self.navigationController.navigationBar.layer.shadowColor = [UIColor blackColor].CGColor;
    self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(0.0, 2.0);
    self.navigationController.navigationBar.layer.shadowOpacity = 0.5;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    [self createTransition];
    //[_calculateButton setBackgroundColor:[UIColor paperColorBlue]];
    [_calculateButton setTitle:@"Calculate" forState:UIControlStateNormal];
    _calculateButton.cornerRadius = 5.0f;
    [_calculateButton setBackgroundColor:[UIColor paperColorAmber700]];
    _calculateButton.rippleFromTapLocation = YES;
    [self.calculateButton addTarget:self action:@selector(didPresentControllerButtonTouch) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:_calculateButton];
    // Do any additional setup after loading the view.
}
- (void)adViewDidReceiveAd:(GADBannerView *)adView {
    NSLog(@"adViewDidReceiveAd");
    adView.alpha = 0;
    [UIView animateWithDuration:1.0 animations:^{
        adView.alpha = 1;
    }];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"EnterInfoScreen"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Ad"
                                                          action:@"Ad Filled"
                                                           label:nil
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
    
}

/// Tells the delegate an ad request failed.
- (void)adView:(GADBannerView *)adView
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"adView:didFailToReceiveAdWithError: %@", [error localizedDescription]);
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"EnterInfoScreen"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Ad"
                                                          action:@"Ad Failed To Fill"
                                                           label:nil
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
}

/// Tells the delegate that a user click will open another app (such as
/// the App Store), backgrounding the current app.
- (void)adViewWillLeaveApplication:(GADBannerView *)adView {
    NSLog(@"adViewWillLeaveApplication");
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"EnterInfoScreen"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Ad"
                                                          action:@"Ad Left App"
                                                           label:nil
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
}
-(void)dismissKeyboard {
    [self.snowDayTF resignFirstResponder];
    [self.ZipCodeTF resignFirstResponder];
}
- (void)createTransition
{
    // self.presentControllerButton is the animatedView used for the transition
    self.transition = [[JTMaterialTransition alloc] initWithAnimatedView:self.calculateButton];
}

// Indicate which transition to use when you this controller present a controller
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    self.transition.reverse = NO;
    return self.transition;
}

// Indicate which transition to use when the presented controller is dismissed
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.transition.reverse = YES;
    return self.transition;
}
- (IBAction)showDetailsAction:(UIButton *)sender event:(UIEvent *)event {
    [[NSUserDefaults standardUserDefaults]setObject:_snowDayTF.text forKey:@"numSnowDays"];
    [[NSUserDefaults standardUserDefaults]setObject:_ZipCodeTF.text forKey:@"zipCode"];
    [[NSUserDefaults standardUserDefaults]synchronize];

    ViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"vcid"];
    self.navigationController.navigationBarHidden = YES;
    [self presentLHViewController:controller tapView:sender color:[UIColor paperColorIndigo] animated:YES completion:^{
        
    }];
}
- (void)didPresentControllerButtonTouch
{
    //self.calculateButton.isRaised = NO;
    //[self.calculateButton setIsRaised:NO];
    [self.calculateButton setShadowColor:[UIColor clearColor]];
    [[NSUserDefaults standardUserDefaults]setObject:_snowDayTF.text forKey:@"numSnowDays"];
    [[NSUserDefaults standardUserDefaults]setObject:_ZipCodeTF.text forKey:@"zipCode"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    // The controller you want to present
    
    ViewController *controller = (ViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"vcid"];
    
    // Indicate you use a custom transition
    controller.modalPresentationStyle = UIModalPresentationCustom;
    controller.transitioningDelegate = self;
    [self.view layoutIfNeeded];
    self.heightConstraint.constant = 100;
    self.widthConsraint.constant = 100;
    [UIView animateWithDuration:.1
                     animations:^{
                         [self.view layoutIfNeeded]; // Called on parent view
                         self.calculateButton.layer.cornerRadius = 50;
                     }];
    [self presentViewController:controller animated:YES completion:nil];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"EnterInfoScreen"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Event"
                                                          action:@"Calculate Click"
                                                           label:[NSString stringWithFormat:@"%@ %@",_snowDayTF.text,_ZipCodeTF.text]
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

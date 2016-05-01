//
//  ViewController.m
//  Snow Day Calculator
//
//  Created by Daniel Katz on 2/7/16.
//  Copyright © 2016 Stratton Design. All rights reserved.
//
#import "Reachability.h"
#import "Appirater.h"
#import "ViewController.h"
@interface ViewController ()

@end

@implementation ViewController
- (void)getWeatherData{
    NSString *zipCode = [[NSUserDefaults standardUserDefaults]objectForKey:@"zipCode"];

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.wunderground.com/api/83873e7d55fee299/forecast/q/%@.json",zipCode]]];
    __block NSDictionary *json;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               json = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:0
                                                                        error:nil];
                               NSDictionary *Forcast = [json objectForKey:@"forecast"];
                               NSDictionary *SimpleForcast = [Forcast objectForKey:@"simpleforecast"];
                               NSArray *ForcastDays = [SimpleForcast objectForKey:@"forecastday"];
                               
                               NSDictionary *TodayForcast = [ForcastDays objectAtIndex:0];
                               NSDictionary *todaydateDict = [TodayForcast objectForKey:@"date"];
                               NSString *today = [[todaydateDict objectForKey:@"weekday"] lowercaseString];
                               
                               
                               
                               if ([today isEqualToString:@"saturday"]) {
                                   indextopull = 2;
                               }
                               else if ([today isEqualToString:@"sunday"]){
                                   indextopull = 1;
                               }
                               else if ([today isEqualToString:@"friday"]){
                                   indextopull = 3;
                               }
                               else{
                                   indextopull = 1;
                               }
                               NSDictionary *TommorowForcast = [ForcastDays objectAtIndex:indextopull];
                               NSDictionary *lowDict = [TommorowForcast objectForKey:@"low"];
                               NSString *lowTemp = [lowDict objectForKey:@"fahrenheit"];
                               NSDictionary *snowDict = [TommorowForcast objectForKey:@"snow_allday"];
                               NSString *snow = [snowDict objectForKey:@"in"];
                               NSDictionary *windDict = [TommorowForcast objectForKey:@"maxwind"];
                               NSString *windspeed1 = [windDict objectForKey:@"mph"];
                               NSDictionary *dateDict = [TommorowForcast objectForKey:@"date"];
                               NSString *dayOfWeekk = [dateDict objectForKey:@"weekday"];
                               self.detailLabel.text = [NSString stringWithFormat:@"Chance of a snowday on %@",dayOfWeekk];
                               NSString *monthInYear = [dateDict objectForKey:@"monthname"];
                               DayOfWeek = dayOfWeekk.lowercaseString;
                               Month = monthInYear.lowercaseString;
                               Temp = lowTemp.intValue;
                               WindSpeed = windspeed1.intValue;
                               InchesOfSnow = snow.intValue;
                               NSURLRequest *request1 = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.wunderground.com/api/83873e7d55fee299/alerts/q/%@.json",zipCode]]];

                               __block NSDictionary *json;
                               [NSURLConnection sendAsynchronousRequest:request1
                                                                  queue:[NSOperationQueue mainQueue]
                                                      completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                                          json = [NSJSONSerialization JSONObjectWithData:data
                                                                                                 options:0
                                                                                                   error:nil];
                                                          NSArray *alertArray = [json objectForKey:@"alerts"];
                                                          NSMutableArray *containsArray = [[NSMutableArray alloc]init];
                                                          for (NSDictionary *dict in alertArray) {
                                                              [containsArray addObject:[dict objectForKey:@"type"]];
                                                          }
                                                          if ([containsArray containsObject:@"WIN"]) {
                                                              SnowStormWarning = YES;
                                                          }
                                                          else{
                                                              SnowStormWarning = NO;
                                                          }
                                                          [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                                                          [self InitiateAlgorithim];
                                                      }];
                               
                               
                               
                           }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self testInternetConnection];
    self.screenName = @"SnowDayChanceScreen";

    self.percentLabel.layer.shadowColor = [[UIColor lightGrayColor] CGColor];
    self.percentLabel.layer.shadowOpacity = 1.0;
    self.percentLabel.layer.shadowOffset = CGSizeMake(0,1);

    self.detailLabel.layer.shadowColor = [[UIColor lightGrayColor] CGColor];
    self.detailLabel.layer.shadowOpacity = 1.0;
    self.detailLabel.layer.shadowOffset = CGSizeMake(0,1);
    
    self.adBannerView2.adUnitID = @"ca-app-pub-2350587744441133/9222724800";
    self.adBannerView2.rootViewController = self;
    self.adBannerView2.delegate = self;
    GADRequest *requester = [GADRequest request];
    // Requests test ads on devices you specify. Your test device ID is printed to the console when
    // an ad request is made. GADBannerView automatically returns test ads when running on a
    // simulator.
    requester.testDevices = @[ kGADSimulatorID ];
    [self.adBannerView2 loadRequest:requester];
    
    [self.materialImageView setImage:[UIImage imageNamed:@"materialLandscape.png"]];
    [self.tempView sendSubviewToBack:self.materialImageView];


    NumberOfSnowdays = [[[NSUserDefaults standardUserDefaults]objectForKey:@"numSnowDays"] intValue];

    
    self.percentLabel.hidden = YES;
    
    loader = [[YRActivityIndicator alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - 50, self.percentLabel.frame.origin.y, 100, 100)];
    loader.itemColor = [UIColor whiteColor];
    loader.cycleDuration = 1.5;
    loader.radius = 45;
    [self.view addSubview:loader];
    //[loader startAnimating];
    [NSTimer scheduledTimerWithTimeInterval:3.0f
                                     target:self selector:@selector(stopLoading) userInfo:nil repeats:NO];
    
    self.tempView.layer.masksToBounds = false;
    self.tempView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.tempView.layer.shadowOffset = CGSizeMake(0.0, 2.0);
    self.tempView.layer.shadowOpacity = 0.5;
    [self.view bringSubviewToFront:self.tempView];
    [self.view bringSubviewToFront:loader];

    //All data gathered
    
    [self.shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.shareButton setBackgroundColor:[UIColor paperColorAmber700]];
    self.shareButton.usesSmartColor = YES;
    self.shareButton.cornerRadius = 30;
    self.shareButton.rippleFromTapLocation = YES;
    self.shareButton.shadowColor = [UIColor paperColorAmber900];
    [self.view bringSubviewToFront:self.shareButton];

    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)testInternetConnection
{
    internetReachableFoo = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Internet is reachable
    internetReachableFoo.reachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Yayyy, we have the interwebs!");
            NSString *zipCode = [[NSUserDefaults standardUserDefaults]objectForKey:@"zipCode"];
            
            
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://api.wunderground.com/api/83873e7d55fee299/geolookup/q/%@.json",zipCode]]];
            
            __block NSDictionary *json;
            [NSURLConnection sendAsynchronousRequest:request
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                       json = [NSJSONSerialization JSONObjectWithData:data
                                                                              options:0
                                                                                error:nil];
                                       
                                       NSDictionary *loaction = [json objectForKey:@"location"];
                                       NSString *requestURL = [loaction objectForKey:@"requesturl"];
                                       cityUrl = requestURL;
                                       [self getWeatherData];
                                   }];
        });
    };
    
    // Internet is not reachable
    internetReachableFoo.unreachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Someone broke the internet :(");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection"
                                                            message:@"Sorry, you need internet connection."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        });
    };
    
    [internetReachableFoo startNotifier];
}

- (void)adViewDidReceiveAd:(GADBannerView *)adView {
    NSLog(@"adViewDidReceiveAd");
    adView.alpha = 0;
    [UIView animateWithDuration:1.0 animations:^{
        adView.alpha = 1;
    }];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName value:@"SnowDayChanceScreen"];
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
    [tracker set:kGAIScreenName value:@"SnowDayChanceScreen"];
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
    [tracker set:kGAIScreenName value:@"SnowDayChanceScreen"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Ad"
                                                          action:@"Ad Left App"
                                                           label:nil
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
}

-(void)stopLoading{
    [UIView animateWithDuration:1.0f animations:^{
        
        [loader setAlpha:0.0f];
        [loader setRadius:0.0];
        
    } completion:^(BOOL finished) {
        [loader removeFromSuperview];
        [self.percentLabel setAlpha:0.0f];
        self.percentLabel.hidden = NO;
        [self.percentLabel setFont:[UIFont systemFontOfSize:0.0]];
        //fade out
        [UIView animateWithDuration:1.0f animations:^{

            [self.percentLabel setFont:[UIFont systemFontOfSize:91.0]];

            
            [self.percentLabel setAlpha:1.0f];
            
        } completion:nil];
        
    }];
}

-(void)updateScoreByAdding: (int)points{
   
    Score = Score + points;

}

-(void)InitiateAlgorithim{
   
    [self calculateDayOfWeekPointsWithDay:DayOfWeek];
    
    [self calculateSnowDayPointsWithNumberOfSnowDays:NumberOfSnowdays :Month];
    
    [self tempPointsWithTemp:Temp];
    
    [self windPointsWithWindSpeed:WindSpeed];
    
    [self snowPointsWithInches:InchesOfSnow];
    
    [self snowStormWarningPointsWithWarning:SnowStormWarning];
    
    int SnowDayScore = [self completeAlgorithim];
    
    if (SnowDayScore >= 100) {
        SnowDayScore = 99;
    }
    else{
        SnowDayScore = SnowDayScore;
    }
    
    if (SnowDayScore > 0 && SnowDayScore <= 40) {
        prediction = @"Little to no chance of a delay or snow day.";
    }
    else if (SnowDayScore >40 && SnowDayScore <=60){
        prediction = @"Possibility of delay, but very small chance of a snow day";
    }
    else if (SnowDayScore > 60 && SnowDayScore <= 80){
        prediction = @"Possibility of Snow Day, high chance of a delay";
    }
    else{
        [Appirater userDidSignificantEvent:YES];
        prediction = @"Vey high chance of a snow day, get ready to sled!";
    }
    
    [self.tableView reloadData];
    
    [self.progressView setValue:(float)SnowDayScore animateWithDuration:1];
    
    self.percentLabel.text = [NSString stringWithFormat:@"%d%%",SnowDayScore];

}

-(void)calculateDayOfWeekPointsWithDay: (NSString *)day{
   
    int points;
    
    if ([day isEqualToString:@"monday"] || [day isEqualToString:@"friday"]) {
    
        points = 5;
    
    }
    else{
        
        points = 0;
    
    }
    
    [self updateScoreByAdding:points];

}

-(void)calculateSnowDayPointsWithNumberOfSnowDays: (int)numberOfSnowDaysand : (NSString *)month{
    
    int points;
    
    switch (NumberOfSnowdays)
    {
        case 0:
            if ([month isEqualToString:@"november"]) {
                points = 14;
            }
            else if ([month isEqualToString:@"december"]){
                points = 9;
            }
            else if ([month isEqualToString:@"january"]){
                points = 7;
            }
            else if ([month isEqualToString:@"february"]){
                points = 9;
            }
            else if ([month isEqualToString:@"march"]){
                points = 14;
            }
            break;
        case 1:
            if ([month isEqualToString:@"november"]) {
                points = 9;
            }
            else if ([month isEqualToString:@"december"]){
                points = 6;
            }
            else if ([month isEqualToString:@"january"]){
                points = 5;
            }
            else if ([month isEqualToString:@"february"]){
                points = 6;
            }
            else if ([month isEqualToString:@"march"]){
                points = 9;
            }
            break;
        case 2:
            if ([month isEqualToString:@"november"]) {
                points = 4;
            }
            else if ([month isEqualToString:@"december"]){
                points = 2;
            }
            else if ([month isEqualToString:@"january"]){
                points = 2;
            }
            else if ([month isEqualToString:@"february"]){
                points = 4;
            }
            else if ([month isEqualToString:@"march"]){
                points = 5;
            }
            break;
        case 3:
            if ([month isEqualToString:@"november"]) {
                points = 0;
            }
            else if ([month isEqualToString:@"december"]){
                points = 1;
            }
            else if ([month isEqualToString:@"january"]){
                points = 1;
            }
            else if ([month isEqualToString:@"february"]){
                points = 1;
            }
            else if ([month isEqualToString:@"march"]){
                points = 3;
            }
            break;
        case 4:
            points = 0;
            break;
        default:
            points = 0;
            break;
    }
    
    
    [self updateScoreByAdding:points];
    
}

-(void)tempPointsWithTemp: (int)temp{
    
    int points;
    
    if (temp < -40 || temp == -40) {
    
        points = 80;
    
    }
    else if (temp > -40 && temp <= -20){
        
        points = 65;
        
    }
    else if (temp > -20 && temp <= 0){
        
        points = 15;
        
    }
    else if (temp > 30){
        
        points = -15;
    }
    else{
        
        points = 0;
        
    }
    
    [self updateScoreByAdding:points];
    
}

-(void)windPointsWithWindSpeed: (int)speed{
    
    int points;
    
    
    if (speed >= 30) {
        
        points = 15;
        
    }
    else if (speed >= 20 && speed <= 29){
        
        points = 10;
        
    }
    else if (speed > 10 && speed <= 19){
        
        points = 7;
        
    }
    else{
        
        points = 0;
        
    }
    
    [self updateScoreByAdding:points];

}

-(void)snowPointsWithInches: (int)inches{
    
    int points;
    
    
    if (inches >= 18) {
        
        points = 75;
        
    }
    else if (inches >= 12 && inches < 18){
        
        points = 40;
        
    }
    else if (inches >= 4 && inches < 12){
        
        points = 25;
        
    }
    else{
        
        points = 0;
        
    }
    
    [self updateScoreByAdding:points];

}

-(void)snowStormWarningPointsWithWarning: (BOOL)Warning{
    
    int points;

    if (Warning == YES && indextopull == 1) {
        
        points = 40;
    
    }
    else{
    
        points = 0;
    
    }
    
    [self updateScoreByAdding:points];

}

-(int)completeAlgorithim{
    
    int percentage;
    
    percentage = Score;
    
    NSString *url = @"http://snowdaypredictor.com/results.html?q=43001";
    NSURL *urlRequest = [NSURL URLWithString:url];
    NSError *err = nil;
    
    NSString *html = [NSString stringWithContentsOfURL:urlRequest encoding:NSUTF8StringEncoding error:&err];
    NSLog(@"the html : %@",html);
    if(err)
    {
        //Handle 
    }
    
    return percentage;
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    int height = self.tableView.frame.size.height/3;
    
    return height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Prediction";
        cell.detailTextLabel.text = prediction;
        [cell.detailTextLabel setFont:[UIFont systemFontOfSize:15.0 weight:0.3]];
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    if (indexPath.row == 1) {
        cell.textLabel.text = @"Predicted Inches Of Snow";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d in",InchesOfSnow];
        [cell.detailTextLabel setFont:[UIFont systemFontOfSize:22.0 weight:0.3]];

    }
    if (indexPath.row == 2) {
        cell.textLabel.text = @"Wind Speed";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d mph",WindSpeed];
        [cell.detailTextLabel setFont:[UIFont systemFontOfSize:22.0 weight:0.3]];

    }
    if (indexPath.row == 4) {
        cell.textLabel.text = @"Snow Storm Warning";
        NSString *warning;
        if (SnowStormWarning == YES && indextopull == 1) {
            warning = @"Yes";
        }
        else{
            warning = @"No";
        }
        cell.detailTextLabel.text = warning;
        cell.detailTextLabel.textColor = [UIColor redColor];
        [cell.detailTextLabel setFont:[UIFont systemFontOfSize:22.0 weight:0.3]];

    }
    if (indexPath.row == 3) {
        cell.textLabel.text = @"Low Tempurature";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d\u00B0",Temp];
        [cell.detailTextLabel setFont:[UIFont systemFontOfSize:22.0 weight:0.3]];

    }
    cell.textLabel.textColor = [UIColor grayColor];
    [cell.textLabel setFont:[UIFont systemFontOfSize:15.0]];
    cell.userInteractionEnabled = NO;
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)shareClicked:(id)sender {
    NSString *textToShare = [NSString stringWithFormat:@"%d%% %@.\n\nShared via Snow Day App for iOS : ",(int)self.progressView.value,_detailLabel.text];
    NSURL *appUrl = [NSURL URLWithString:@"https://itunes.apple.com/app/snow-day-app/id1082537754"];
    
    NSArray *objectsToShare = @[textToShare, appUrl];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    [activityVC setCompletionHandler:^(NSString *activityType, BOOL completed) {
        if (completed == YES) {
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker set:kGAIScreenName value:@"SnowDayChanceScreen"];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Event"
                                                                  action:@"Share Sent"
                                                                   label:activityType
                                                                   value:nil] build]];
            [tracker set:kGAIScreenName value:nil];
        }
    }];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"SnowDayChanceScreen"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Event"
                                                          action:@"Share Clicked"
                                                           label:nil
                                                           value:nil] build]];
    [tracker set:kGAIScreenName value:nil];
    [self presentViewController:activityVC animated:YES completion:nil];
    [Appirater userDidSignificantEvent:YES];

}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"back"]) {
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName value:@"SnowDayChanceScreen"];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Event"
                                                              action:@"Back Clicked"
                                                               label:nil
                                                               value:nil] build]];
        [tracker set:kGAIScreenName value:nil];
    }
}

@end

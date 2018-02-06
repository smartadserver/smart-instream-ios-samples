//
//  AppDelegate.m
//  SVSJWSample
//
//  Created by glaubier on 17/01/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "AppDelegate.h"
#import <SVSVideoKit/SVSVideoKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Constants.h"

@interface AppDelegate () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    ////////////////////////////////////////////
    // SDK - Configuration
    // MANDATORY
    // You will not be able to start the AdManager without doing this.
    ////////////////////////////////////////////
    
    // Configure Smart Instream SDK with your SiteID
    [[SVSConfiguration sharedInstance] configureWithSiteID:SmartInstreamSDK_SiteID];
    
    
    ////////////////////////////////////////////
    // SDK - Debugging
    // OPTIONAL
    // To help you trouble shooting the SDK
    ////////////////////////////////////////////
    
    // Set logging enabled for console logging of SDK events.
    // Note that you should disable the logging when pushing your application on the AppStore.
    [[SVSConfiguration sharedInstance] setLoggingEnabled:YES];
    
    
    /////////////////////////////////////////////
    // SDK - Localization
    // OPTIONAL
    // You can set custom strings to be used by the SDK while displaying ads.
    // Please refer to the documentation for the complete HOW-TO.
    /////////////////////////////////////////////
    
    // Set the main bundle of the app as the source for localized strings.
    //[SVSConfiguration sharedInstance].stringsBundle = [NSBundle mainBundle];
    
    
    ////////////////////////////////////////////
    // SDK - User Location
    // OPTIONAL - Highly recommanded for monetization purposes.
    // It is recommanded that you request authorization for location detection if your app does not already request it
    // before integration of the Instream SDK.
    // If the user grants you the right to detect his location, the SDK will find it automatically and pass it to the ad server when making ad calls,
    // this will allow a better targeting and increase your RTB revenues.
    // Don't forget to setup the NSLocationWhenInUseUsageDescription key in your Info.plist.
    ////////////////////////////////////////////
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    // If you don't want the SDK to use the user's location automatically, you can disable the detection.
    //[SVSConfiguration sharedInstance].allowAutomaticLocationDetection = NO;
    
    // You can also set the location manually by passing a CLLocationCoordinate2D to the SDK.
    //[SVSConfiguration sharedInstance].manualLocation = CLLocationCoordinate2DMake(latitude, longitude);
    
    
    ////////////////////////////////////////////
    // SDK - User Tracking
    // OPTIONAL
    // By default the SDK will use the IDFA of the device to identify the user.
    // If IDFA is not available due to user's privacy settings, SDK will generate a transientID, renewed every 24h.
    // This transientID will not be used for tracking but only for capping purposes.
    ////////////////////////////////////////////
    
    // You can deactivate the transientID if you prefer:
    //[SVSConfiguration sharedInstance].transientIDEnabled = NO;
    
    // You can also set a custom identifier to identify the user, for example to match one of your DMP segments.
    // If you do so, the IDFA will not be passed to the ad server and the user will be only identified by
    // your custom identifier.
    //[SVSConfiguration sharedInstance].customIdentifier = @"CustomIdentifier";
    
    // Override point for customization after application launch.
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end

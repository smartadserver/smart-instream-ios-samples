//
//  SVSConfiguration.h
//  SVSVideoKit
//
//  Created by Thomas Geley on 04/04/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@class SVSAdRules, SVSAdPlayerConfiguration;

/**
 This class hold the global configuration of the SDK.
 All methods called here will impact the whole Video SDK.
 */
@interface SVSConfiguration : NSObject

#pragma mark - Singleton shared instance

/// The shared instance of the SVSConfiguration object.
@property (class, nonatomic, readonly) SVSConfiguration *sharedInstance NS_SWIFT_NAME(shared);

#pragma mark - Configuration initialization

/**
 Configure the SDK for a given siteID. This will customize the SDK behavior for your site ID: for example retrieving automatically your baseURL for faster ad requests, enable specific logging, etc…
 
 @note This method MUST be called before performing any Ad request and *only once per Application's lifecycle*.
 Make sure you call this method in the application:didFinishLaunchingWithOptions: method of your application's delegate.
 
 @param siteID The siteID for your application in Manage interface. Contact your account manager if you have trouble finding this ID.
 */
- (void)configureWithSiteID:(NSUInteger)siteID;

#pragma mark - Misc configuration options

/// true if the SDK needs to display debug informations in the Xcode console, false otherwise.
@property (nonatomic, assign) BOOL loggingEnabled;

/// true if location information can be used automatically by the SDK (if available), false otherwise.
@property (nonatomic, assign) BOOL allowAutomaticLocationDetection;

/// Coordinate that will be used instead of the actual device location (for testing purpose for instance), kCLLocationCoordinate2DInvalid otherwise (default value).
@property (nonatomic, assign) CLLocationCoordinate2D manualLocation;

/// The custom identifier for this device. Setting this property will override the IDFA of this device when requesting an Ad.
@property (nullable, nonatomic, strong) NSString *customIdentifier;

/// The ad rules that will be used for any ad player where ad rules are not specified.
/// Default rule for finite duration content is one preroll ad and one postroll ad. Default rule for live content is one preroll ad.
@property (nonatomic, strong) SVSAdRules *defaultAdRules;

/// The ad player configuration that will be used for any ad player where ad player configuration is not specified.
@property (nonatomic, strong) SVSAdPlayerConfiguration *defaultAdPlayerConfiguration;

/// The bundle for localized strings - See documentation for keys. By default the strings of the framework bundle will be used.
@property (nonatomic, strong) NSBundle *stringsBundle;

#pragma mark - Read-only configuration properties

/// The baseURL for ad calls.
@property (nonatomic, readonly) NSURL *baseURL;

/// The siteID associated with this SDK configuration.
@property (nonatomic, readonly) NSUInteger siteID;

/// The networkID associated with this SDK configuration.
@property (nonatomic, readonly) NSUInteger networkID;

/// The version of the Video SDK.
@property (nonatomic, readonly) NSString *version;

@end

NS_ASSUME_NONNULL_END

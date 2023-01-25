//
//  SVSAdConfiguration.h
//  SVSVideoKit
//
//  Created by Thomas Geley on 27/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SVSAdPlayerConfigurationDisplayOptions, SVSAdPlayerConfigurationPublisherOptions, SVSAdPlayerConfigurationRTBOptions, SVSAdPlayerConfigurationVPAIDOptions;

/**
 Configuration of the ad player.
 */
@interface SVSAdPlayerConfiguration : NSObject <NSCopying, NSCoding>

#pragma mark - Configuration initialization

/**
 Initialize a new instance of SVSAdPlayerConfiguration with the default configuration.
 
 @return The initialized SVSAdPlayerConfiguration instance.
 */
- (instancetype)init NS_DESIGNATED_INITIALIZER;

/**
 Initialize a new instance of SVSAdPlayerConfiguration from a JSON configuration.
 
 Any configuration parameter not defined in this JSON will be initialized with its default value, any
 additional parameter not supported in the SDK will be ignored.
 
 @param json A string containing an ad player configuration JSON.
 @return The initialized SVSAdPlayerConfiguration instance, or nil if the JSON is invalid.
 */
- (nullable instancetype)initWithJSON:(NSString *)json;

/**
 Asynchronously retrieve a JSON based ad player configuration set from a given URL.
 
 Any configuration parameter not defined in this JSON will be initialized with its default value, any
 additional parameter not supported in the SDK will be ignored.
 
 @warning The execution thread for the completion handler is not guaranteed. If you make UI modification in this handler, make sure to perform them on the main thread.
 
 @param adPlayerConfigurationURL The URL of the JSON describing the ad player configuration.
 @param completionHandler The completion handler that will be called with the SVSAdPlayerConfiguration object.
 */
+ (void)adPlayerConfigurationFromURL:(NSURL *)adPlayerConfigurationURL completionHandler:(void(^)(SVSAdPlayerConfiguration * _Nullable, NSError * _Nullable))completionHandler;

#pragma mark - Sub-configuration properties

/// Display configuration.
@property (nonatomic, readonly) SVSAdPlayerConfigurationDisplayOptions *displayOptions;

/// Publisher options.
@property (nonatomic, readonly) SVSAdPlayerConfigurationPublisherOptions *publisherOptions;

/// RTB options.
@property (nonatomic, readonly) SVSAdPlayerConfigurationRTBOptions *RTBOptions;

/// VPAID ads options.
@property (nonatomic, strong) SVSAdPlayerConfigurationVPAIDOptions *VPAIDOptions;

@end

NS_ASSUME_NONNULL_END

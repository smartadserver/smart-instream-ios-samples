//
//  SVSFrameworkInfo.h
//  SVSVideoKit
//
//  Created by Loïc GIRON DIT METAZ on 04/04/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Retrieve some informations about the SVSVideoKit framework.
 */
@interface SVSFrameworkInfo : NSObject

/// The shared instance of the SVSFrameworkInfo object.
@property (class, nonatomic, readonly) SVSFrameworkInfo *sharedInstance NS_SWIFT_NAME(shared);

/// The framework's name.
@property (nonatomic, readonly) NSString *frameworkName;

/// The framework's marketing name (the name used in Cocoapods for instance).
@property (nonatomic, readonly) NSString *frameworkMarketingName;

/// The framework's bundle identifier.
@property (nonatomic, readonly) NSString *frameworkBundleIdentifier;

/// The framework's version string.
@property (nonatomic, readonly) NSString *frameworkVersionString;

@end

NS_ASSUME_NONNULL_END

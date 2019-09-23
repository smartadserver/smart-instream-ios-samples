//
//  SVSAdRules.h
//  SVSVideoKit
//
//  Created by Thomas Geley on 27/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVSAdRule.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Represents a set of ad rules.
 */
@interface SVSAdRules : NSObject <NSCopying, NSCoding>

#pragma mark - Initializers

/**
 Initialize a SVSAdRules instance from an array of valid ad rules.
 
 @param adRules An array of valid SVSAdRule instances.
 @return An initialized SVSAdRules instance or nil if the adRules array is empty.
 */
- (nullable instancetype)initWithRules:(NSArray <SVSAdRule *> *)adRules NS_DESIGNATED_INITIALIZER;

/**
 Initialize a SVSAdRules instance from a valid ad rules JSON.
 
 @param jsonRules A string containing a valid ad rules JSON.
 @return An initialized SVSAdRules instance or nil if the JSON is not valid.
 */
- (nullable instancetype)initWithJSON:(NSString *)jsonRules;

#pragma mark - Convenience initializers

/**
 Creates a SVSAdRules instance from an array of valid ad rules.
 
 @param adRules An array of valid SVSAdRule instances.
 @return An initialized SVSAdRules instance.
 */
+ (instancetype)adRulesWithRules:(NSArray <SVSAdRule *> *)adRules;

/**
 Creates a SVSAdRules instance from a valid ad rules JSON.
 
 @param jsonRules A string containing a valid ad rules JSON.
 @return An initialized SVSAdRules instance or nil if the JSON is not valid.
 */
+ (instancetype)adRulesWithJSON:(NSString *)jsonRules;

/**
 Asynchronously retrieve a JSON based ad rules set from a given URL.
 
 @warning The execution thread for the completion handler is not guaranteed. If you make UI modification in this handler, make sure to perform them on the main thread.
 
 @param adRulesURL The URL of the JSON describing the ad rules.
 @param completionHandler The completion handler that will be called with the SVSAdRules object (or with an error if the ad rules object can be retrieved).
 */
+ (void)adRulesFromURL:(NSURL *)adRulesURL completionHandler:(void(^)(SVSAdRules * _Nullable, NSError * _Nullable))completionHandler;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

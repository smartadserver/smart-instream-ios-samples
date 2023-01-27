//
//  SVSAdRuleData.h
//  SVSVideoKit
//
//  Created by Loïc GIRON DIT METAZ on 06/04/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Type of ad break of the data rule.
typedef NS_ENUM(NSUInteger, SVSAdRuleDataType) {
    /// Preroll ad break.
    SVSAdRuleDataTypePreroll,
    
    /// Midroll ad break.
    SVSAdRuleDataTypeMidroll,
    
    /// Postroll ad break.
    SVSAdRuleDataTypePostroll,
    
    /// Overlay ad (unused for now).
    SVSAdRuleDataTypeOverlay,
};

/**
 Represents the details of an ad rule related to a given ad break type.
 */
@interface SVSAdRuleData : NSObject <NSCopying, NSCoding>

#pragma mark - Convenience initializers

/**
 Returns an initialized ad rule data object for a preroll ad break.
 
 @param instances 0 to disable the ad break, a positive number to override the default number of ads in the ad break.
 @return An initialized SVSAdRuleData instance.
 */
+ (nullable instancetype)prerollDataWithInstances:(NSUInteger)instances;

/**
 Returns an initialized ad rule data object for a postroll ad break.
 
 @param instances 0 to disable the ad break, a positive number to override the default number of ads in the ad break.
 @return An initialized SVSAdRuleData instance.
 */
+ (nullable instancetype)postrollDataWithInstances:(NSUInteger)instances;

/**
 Returns an initialized ad rule data object for a midroll ad break.
 
 @param instances 0 to disable the ad break, a positive number to override the default number of ads in the ad break.
 @param percents Array of percentages where the ad break should happen (irrelevant for streamed content).
 @return An initialized SVSAdRuleData instance.
 */
+ (nullable instancetype)midrollDataWithInstances:(NSUInteger)instances percents:(NSArray <NSNumber *> *)percents;

/**
 Returns an initialized ad rule data object for a midroll ad break.
 
 @param instances 0 to disable the ad break, a positive number to override the default number of ads in the ad break.
 @param timecodes Array of timecodes where the ad break should happen (irrelevant for streamed content).
 @return An initialized SVSAdRuleData instance.
 */
+ (nullable instancetype)midrollDataWithInstances:(NSUInteger)instances timecodes:(NSArray <NSString *> *)timecodes;

/**
 Returns an initialized ad rule data object for a midroll ad break.
 
 @note An offset of 0 will be set when using this initializer.
 
 @param instances 0 to disable the ad break, a positive number to override the default number of ads in the ad break.
 @param interval Interval (in seconds) between two ad break.
 @return An initialized SVSAdRuleData instance.
 */
+ (nullable instancetype)midrollDataWithInstances:(NSUInteger)instances interval:(NSTimeInterval)interval;

/**
 Returns an initialized ad rule data object for a midroll ad break.
 
 @param instances 0 to disable the ad break, a positive number to override the default number of ads in the ad break.
 @param interval Interval (in seconds) between two ad break.
 @param offset Offset (in seconds) before the first ad break when an interval is defined.
 @return An initialized SVSAdRuleData instance.
 */
+ (nullable instancetype)midrollDataWithInstances:(NSUInteger)instances interval:(NSTimeInterval)interval offset:(NSTimeInterval)offset;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

//
//  SVSAdRule.h
//  SVSVideoKit
//
//  Created by Loïc GIRON DIT METAZ on 06/04/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVSAdRuleData.h"

#define kSVSAdRuleInfiniteDuration NSIntegerMax

NS_ASSUME_NONNULL_BEGIN

/**
 Represents an ad rule for a particular media duration.
 All durations are expressed in seconds.
 */
@interface SVSAdRule : NSObject <NSCopying, NSCoding>

#pragma mark - Convenience initializers

/**
 Returns a SVSAdRule instance.
 
 @param data The data of the ad rule (see SVSAdRuleData).
 @param durationMin The minimum duration of the media for this ad rule.
 @param durationMax The maximum duration of the media for this ad rule (kSVSAdRuleInfiniteDuration means no maximum duration).
 @param minimumDelayBetweenAdBreaks The minimum duration of content's playback between two linear Ad Breaks for this ad rule.
 @return An initialized SVSAdRule instance.
 */
+ (nullable instancetype)adRuleWithData:(NSArray <SVSAdRuleData *> *)data durationMin:(NSTimeInterval)durationMin durationMax:(NSTimeInterval)durationMax minimumDelayBetweenAdBreaks:(NSTimeInterval)minimumDelayBetweenAdBreaks;

/**
 Returns a SVSAdRule instance.
 
 @param data The data of the ad rule (see SVSAdRuleData).
 @param durationMin The minimum duration of the media for this ad rule.
 @param durationMax The maximum duration of the media for this ad rule (kSVSAdRuleInfiniteDuration means no maximum duration).
 @return An initialized SVSAdRule instance.
 */
+ (nullable instancetype)adRuleWithData:(NSArray <SVSAdRuleData *> *)data durationMin:(NSTimeInterval)durationMin durationMax:(NSTimeInterval)durationMax;

/**
 Returns a SVSAdRule instance without minimum duration constraint.
 
 @param data The data of the ad rule (see SVSAdRuleData).
 @param durationMax The maximum duration of the media for this ad rule (kSVSAdRuleInfiniteDuration means no maximum duration).
 @return An initialized SVSAdRule instance.
 */
+ (nullable instancetype)adRuleWithData:(NSArray <SVSAdRuleData *> *)data durationMax:(NSTimeInterval)durationMax;

/**
 Returns a SVSAdRule instance without maximum duration constraint.
 
 @param data The data of the ad rule (see SVSAdRuleData).
 @param durationMin The minimum duration of the media for this ad rule.
 @return An initialized SVSAdRule instance.
 */
+ (nullable instancetype)adRuleWithData:(NSArray <SVSAdRuleData *> *)data durationMin:(NSTimeInterval)durationMin;

/**
 Returns a SVSAdRule instance for a live stream content.
 
 @param data The data of the ad rule (see SVSAdRuleData).
 @param minimumDelayBetweenAdBreaks The minimum duration of content's playback between two linear Ad Breaks for this ad rule.
 @return An initialized SVSAdRule instance.
 */
+ (nullable instancetype)adRuleForLiveStreamContentWithData:(NSArray <SVSAdRuleData *> *)data minimumDelayBetweenAdBreaks:(NSTimeInterval)minimumDelayBetweenAdBreaks;

#pragma mark - Ad rule properties

/// The minimum duration of the media for this ad rule.
@property (nonatomic, readonly) NSTimeInterval durationMin;

/// The maximum duration of the media for this ad rule (-1 means no maximum duration).
@property (nonatomic, readonly) NSTimeInterval durationMax;

/// The minimum duration between 2 Midrolls breaks to avoid users seeking through content to hit too many breaks. (default: 0 second).
@property (nonatomic, readonly) NSTimeInterval minimumDelayBetweenAdBreaks;

/// Returns all rule data objects of this ad rule (see SVSAdRuleData).
@property (nonatomic, readonly) NSArray <SVSAdRuleData *> *data;

/// The preroll data object of this ad rule if any, nil otherwise.
@property (nullable, nonatomic, readonly) SVSAdRuleData *prerollData;

/// The midroll data object of this ad rule if any, nil otherwise.
@property (nullable, nonatomic, readonly) SVSAdRuleData *midrollData;

/// The postroll data object of this ad rule if any, nil otherwise.
@property (nullable, nonatomic, readonly) SVSAdRuleData *postrollData;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

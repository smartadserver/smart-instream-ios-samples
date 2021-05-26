//
//  SVSAdPlayerConfigurationRTBOptions.h
//  SVSVideoKit
//
//  Created by Loïc GIRON DIT METAZ on 18/04/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Playback method used by the video player
typedef NS_ENUM(NSInteger, SVSAdPlayerConfigurationPlaybackMethod) {
    /// The playback method information is undefined and will not be passed to RTB requests.
    SVSAdPlayerConfigurationPlaybackMethodUndefined = -1,
    
    /// The video is autoplayed, with sound ON by default.
    SVSAdPlayerConfigurationPlaybackMethodAutoplaySoundOn = 1,
    
    /// The video is autoplayed, with sound OFF by default.
    SVSAdPlayerConfigurationPlaybackMethodAutoplaySoundOff = 2,
    
    /// The video is played manually when clicked.
    SVSAdPlayerConfigurationPlaybackMethodClickToPlay = 3,
};

/**
 Hold the configuration for RTB requests.
 */
@interface SVSAdPlayerConfigurationRTBOptions : NSObject <NSCopying>

#pragma mark - Initialization

/**
 Initialize a new instance of SVSAdPlayerConfigurationRTBOptions with the default configuration.
 
 @return The initialized SVSAdPlayerConfigurationRTBOptions instance.
 */
- (instancetype)init;

#pragma mark - Configuration properties

/**
 The minimum duration (in seconds) for requested video creatives.
 
 This information will be sent in the ad request only if greater than 0.

 Default: -1
*/
@property (nonatomic, assign) NSTimeInterval minimumVideoDuration;

/**
 The maximum duration (in seconds) for requested video creatives.

 This information will be sent in the ad request only if greater than 0.

 Default: -1
*/
@property (nonatomic, assign) NSTimeInterval maximumVideoDuration;

/**
 The minimum bitrate (in kbps) for requested video creatives.

 This information will be sent in the request only if greater than 0.

 Default: -1
*/
@property (nonatomic, assign) double minimumVideoBitrate;

/**
 The maximum bitrate (in kbps) for the programmatically requested video creatives.

 This information will be sent in the request only if greater than 0.

 Default: -1
*/
@property (nonatomic, assign) double maximumVideoBitrate;

/**
 The playback method used by the video player.

 Default: SVSAdPlayerConfigurationPlaybackMethodUndefined
*/
@property (nonatomic, assign) SVSAdPlayerConfigurationPlaybackMethod playbackMethod;

/**
 The page domain of the website for your app. For example: www.smartadserver.com.
 This parameter is very useful for buyers to identify your network.
 
 Default: Nil.
 */
@property (nullable, nonatomic, strong) NSString *pageDomain;

@end

NS_ASSUME_NONNULL_END

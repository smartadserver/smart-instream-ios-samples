//
//  SVSAdPlayerConfigurationPublisherOptions.h
//  SVSVideoKit
//
//  Created by Loïc GIRON DIT METAZ on 18/04/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Hold the configuration options related to the publisher.
 */
@interface SVSAdPlayerConfigurationPublisherOptions : NSObject <NSCopying>

#pragma mark - Initialization

/**
 Initialize a new instance of SVSAdPlayerConfigurationPublisherOptions with the default configuration.
 
 @return The initialized SVSAdPlayerConfigurationPublisherOptions instance.
 */
- (instancetype)init;

#pragma mark - Configuration properties

/**
 Indicates it the Skip Offset attribute from VAST ads should be ignored. If YES, the skipDelay property from this class will be used instead.

 Default: NO
*/
@property (nonatomic, assign) BOOL forceSkipDelay;

/**
 Duration in seconds after which a linear ad can be skipped when forceSkipDelay is set to YES.
 
 Use -1 to make creatives not skippable. Use 0 to make creative skippable immediately. Use a positive value for actual delay.

 Default: -1
*/
@property (nonatomic, assign) NSTimeInterval skipDelay;

/**
 YES if the AdManager should pause the content player at exact Ad break time even if Ad break data are not loaded yet. When NO, the AdManager will pause the content player only when the AdBreak is ready to be played.
 
 Default: YES
*/
@property (nonatomic, assign) BOOL pauseMainContentUntilVASTIsLoaded;

/**
 Total time allowed for an AdBreak request. If the total timeout is reached before any ad is displayed, the AdBreak is cancelled and the content player is resumed.

 Default: 8s
*/
@property (nonatomic, assign) NSTimeInterval totalTimeout;

/**
 Time allowed for a single HTTP request. This timeout should always be smaller than totalTimeout.

 Default: 3s
*/
@property (nonatomic, assign) NSTimeInterval requestTimeout;

/**
 Time allowed for stall. If the stall timeout is reached before the ad can resume, the AdBreak playback is cancelled and the content player is resumed.

 Default: 10s
*/
@property (nonatomic, assign) NSTimeInterval stallTimeout;

/**
 Maximum wrapper redirection depth. This depth limitation is important to ensure that there will be no wrapper loop.

 Default: 5
*/
@property (nonatomic, assign) NSInteger maximumNumberOfRedirects;

/**
 Number of passback ads returned in by the Ad Server.
 
 Value of 0 will disable passback ads. A positive number will return a precise number of passback ads.

 Default value is -1, meaning the delivery engine will choose the best value for passback ads.
*/
@property (nonatomic, assign) NSInteger numberOfPassbackAds;

/**
 YES if ads should be played again when the content video is rewinded.

 Default: YES
*/
@property (nonatomic, assign) BOOL replayAds;

/**
 YES if ad breaks should be played automatically.
 
 Default: YES
 */
@property (nonatomic, assign) BOOL enableAdBreakAutoplay;

/**
 YES if you prefer to use Server-Side Ad-Rules for number of Ad Instances during each Ad Break.

 Default: NO
*/
@property (nonatomic, assign) BOOL enableSSAR;

/**
 YES if you want to apply strict UniversalAdId control policy.
 
 When activated, the SDK will discard every creative with a null or "unknown" UniversalAdId identification and replace it with a passback when possible.
 Additionally, an ad identified with an UniversalAdId will not be displayed more than once in the same ad break and will be replaced by a passback when possible.
 
 @note This feature is only available since VAST 4.0. If activated, every ad response with an inferior VAST version will be discarded.
 
 Default: NO
*/
@property (nonatomic, assign) BOOL enableUniversalAdIdControlPolicy;

/**
 When NO, the whole ad player layer view is clickable. When YES, a clickthrough button will be displayed above the video layer.

 Default: NO
*/
@property (nonatomic, assign) BOOL enableClickThroughButton;

/**
 YES to enable VPAID ads, NO to disable them.

 Default: YES
*/
@property (nonatomic, assign) BOOL enableVPAID;

@end

NS_ASSUME_NONNULL_END

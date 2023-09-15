//
//  SVSAdManagerDelegate.h
//  SVSVideoKit
//
//  Created by Thomas Geley on 27/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <SVSVideoKit/SVSEnums.h>

NS_ASSUME_NONNULL_BEGIN

@class SVSAdManager;

/**
 Delegate protocol for SVSAdManager instances.
 
 Use it if you want more information about the ad break that is being played, about errors or 
 about user interactions.
 */
@protocol SVSAdManagerDelegate <NSObject>

#pragma mark - Manager Start Informations

/**
 Called when an ad manager instance fails to start. This can occur for several reasons such as contentPlayhead not ready, etc. See error for more informations.
 
 @param adManager The SVSAdManager instance that failed to start.
 @param error A NSError instance corresponding to the error.
 */
- (void)adManager:(SVSAdManager *)adManager didFailToStartWithError:(NSError *)error;

#pragma mark - Ad Break Informations

/**
 Called when an ad manager instance fails to play an ad break.
 
 @param adManager The SVSAdManager instance that failed to start an AdBreak.
 @param adBreakType The ad break type (overlay, preroll, midroll, postroll).
 @param error A NSError instance corresponding to the error.
 */
- (void)adManager:(SVSAdManager *)adManager didFailToStartAdBreak:(SVSAdBreakType)adBreakType error:(NSError *)error;

/**
 Called when an ad manager instance starts to play an ad break.
 
 @param adManager The SVSAdManager instance that started.
 @param adBreakType The ad break type (overlay, preroll, midroll, postroll).
 */
- (void)adManager:(SVSAdManager *)adManager didStartAdBreak:(SVSAdBreakType)adBreakType;

/**
 Called when an ad manager instance is finishing to play an ad break.
 
 @param adManager The SVSAdManager instance that finished an ad break.
 @param adBreakType The ad break type (overlay, preroll, midroll, postroll).
 @param numberOfAdsPlayed The number of ads played during this ad break.
 @param duration The total duration of the ad break.
 @param error A NSError instance if an error happens, nil otherwise.
 */
- (void)adManager:(SVSAdManager *)adManager didFinishAdBreak:(SVSAdBreakType)adBreakType numberOfAds:(NSInteger)numberOfAdsPlayed duration:(NSTimeInterval)duration error:(nullable NSError *)error;

/**
 Called when an ad manager instance did generate cue points. Can be useful to setup your player.
 
 @param adManager The SVSAdManager instance that finished an ad break.
 @param cuePoints A NSArray containing SVSCuePoint instances. Each SCSVideoCuePoint instance represent the position of an adbreak.
 */
- (void)adManager:(SVSAdManager *)adManager didGenerateCuePoints:(NSArray<SVSCuePoint *> *)cuePoints;

#pragma mark - Playback

/**
 Called when an ad manager instance will start to play ads. You should pause your content player in this method.
 
 @param adManager The SVSAdManager instance about to play an ad.
 @param adBreakType The ad break type (overlay, preroll, midroll, postroll).
 */
- (void)adManagerDidRequestToPauseContentPlayer:(SVSAdManager *)adManager forAdBreak:(SVSAdBreakType)adBreakType;

/**
 Called when an ad manager instance finished to play ads. You should resume your content player in this method.
 
 @param adManager The SVSAdManager instance which finished to play ads.
 @param adBreakType The ad break type (overlay, preroll, midroll, postroll).
 */
- (void)adManagerDidRequestToResumeContentPlayer:(SVSAdManager *)adManager afterAdBreak:(SVSAdBreakType)adBreakType;

/**
 Called periodically to keep track of the ad manager's playback status.
 
 Implement this method for custom tracking, trigger background tasks, etc…
 
 @param adManager The SVSAdManager instance currently playing.
 @param currentTime The current time of the player.
 @param totalTime The total duration of the player's playlist.
 */
- (void)adManager:(SVSAdManager *)adManager didProgressToTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime;

#pragma mark - Fullscreen

/**
 Called when the enter fullscreen button of an Ad is clicked by the user. Adapt your UI to properly react to this user action: you should resize your container view so it fits the whole screen.
 
 @param adManager The SVSAdManager instance asking to enter fullscreen.
 */
- (void)adManagerDidRequestToEnterFullscreen:(SVSAdManager *)adManager;

/**
 Called when the exit fullscreen button of an Ad is clicked by the user. Adapt your UI to properly react to this user action: you should resize your container view so it goes back to its original size.
 
 @param adManager The SVSAdManager instance asking to exit fullscreen.
 */
- (void)adManagerDidRequestToExitFullscreen:(SVSAdManager *)adManager;

#pragma mark - Modal Presentation

/**
 Called when the ad has been clicked and needs to open a modal.
 
 Implement this method and return the appropriate UIViewController to present the post click modal controller.
 
 @param adManager The SVSAdManager instance that needs the current UIViewController.
 @return An UIViewController from which the post click modal controller should be presented.
 */
- (UIViewController *)adManagerDidRequestPostClickPresentationViewController:(SVSAdManager *)adManager;

#pragma mark - Optional

@optional

/**
 Called when the ad break is ready to start.
 
 This method will be called only if the 'enableAdBreakAutoplay' option is disabled. Added to let you start the adBreak when you want,
 more information in the official documentation.
 
 Warning: Do not forget to call [SVSAdManager startAdBreak] when this delegate method is called!
 
 @param adManager The SVSAdManager instance ready to start the ad break.
 @param adBreakType The ad break type (overlay, preroll, midroll, postroll). 
 */
- (void)adManager:(SVSAdManager *)adManager isReadyToStartAdBreak:(SVSAdBreakType)adBreakType;

@end

NS_ASSUME_NONNULL_END

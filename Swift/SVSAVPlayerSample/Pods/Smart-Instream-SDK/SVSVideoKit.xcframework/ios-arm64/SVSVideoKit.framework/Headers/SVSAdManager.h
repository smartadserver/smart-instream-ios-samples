//
//  SVSAdManager.h
//  SVSVideoKit
//
//  Created by Thomas Geley on 27/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SVSAdManagerDelegate, SVSContentPlayerPlayHead;
@class SVSAdPlacement, SVSAdRules, SVSAdPlayerConfiguration, SVSContentData, SVSCuePoint;

/**
 The ad manager is the class responsible of loading ads and displaying them into the ad player.
 
 This class is instantiated with a placement, a set of ad rules, an ad player configuration and is started
 with a play head object (a protocol representing the state of the content player) and an ad container view
 which is the view that will be used as superview by the ad player view.
 */
@interface SVSAdManager : NSObject

#pragma mark - Initialization

/**
 Initialize a new instance of SVSAdManager.
 
 @param delegate The delegate of the ad manager.
 @param placement The placement that should be used to retrieve the ads.
 @param rules Ad rules object used to describe the type of ad the ad manager is allowed to load (and the loading timing for midrolls).
 @param configuration The ad player configuration.
 @param contentData An SVSContentData instance containing informations about the content video.
 @return An initialized instance of SVSAdManager.
 */
- (instancetype)initWithDelegate:(nullable id <SVSAdManagerDelegate>)delegate
                        placement:(SVSAdPlacement *)placement
                            rules:(nullable SVSAdRules *)rules
                   configuration:(nullable SVSAdPlayerConfiguration *)configuration
                     contentData:(nullable SVSContentData *)contentData;

#pragma mark - Playback lifecycle

/**
 Starts the ad manager.
 
 This will allow the ad manager to load and display ads for the content described by the play head protocol.
 
 @param playHead A protocol representing the state of the content player.
 @param adContainerView The container view in which the ad player view will be displayed. 
 */
- (void)startWithPlayHead:(id <SVSContentPlayerPlayHead>)playHead adContainerView:(UIView *)adContainerView;

/**
 * Will start the waiting ad break, if any. To use only if you have disable the adbreak autoplay.
 * Warnings: if you do not call this method, the ad break will never start and the SDK will be paused waiting for this method call.
 * More information in the official documentation.
 */
- (void)startAdBreak;

/**
 Stops the ad manager. 
 Use this method only if your content is stopped by an user action such as clicking on a STOP button on your content player UI.
 Calling this method can trigger a PostRoll advertisement if defined in your AdRules.
 Calling this method has no effect if an Ad break is already being played.
 
 If the content finishes without being interrupted by an user interaction, the Ad Manager will automatically trigger the
 appropriate PostRoll advertisement based on the content player current time, it is not necessary to call this method.
 
 @param triggerPostroll Whether or not the Ad Manager should trigger a postroll ad if any in your SVSAdRule.
 
 */
- (void)stopAndTriggerPostrollIfAny:(BOOL)triggerPostroll;

/**
 Tells the ad manager that your content is being replayed (after being completed). 
 You should make sure your content player seeks to the begining of the content video before calling this method.
 
 This will reset the status of PreRoll and PostRoll advertisements so they can be served again if your AdPlayerConfiguration.publisherOptions.replayAds is YES.
 @note This method has no impact on MidRoll advertisements. They will continue playing according to the appropriate AdRule and playHead status.
 */
- (void)replay;

#pragma mark - Fullscreen management

/**
 Tells the ad manager that your content player entered / exited fullscreen mode.
 
 The AdPlayer view will always stick to your container view even when you resize or rotate it. However, the AdManager needs to know about your fullscreen status to keep the Fullscreen button status up to date when playing Ad breaks. This is particularly important if your application responds to orientation changes by entering / exiting fullscreen.
 
 @param isFullscreen Whether or not the content player is in fullscreen mode.
 */
- (void)contentPlayerIsFullscreen:(BOOL)isFullscreen;

#pragma mark - Properties

/// The delegate of the ad manager.
@property (nonatomic, weak) id <SVSAdManagerDelegate> delegate;

/**
 Tells whether or not the SVSAdManager is started.
 Use this method in your integration to know if you already started your SVSAdManager instance or not.
 
 @return whether or not the SVSAdManager instance has been started.
 */
- (BOOL)isStarted;


- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

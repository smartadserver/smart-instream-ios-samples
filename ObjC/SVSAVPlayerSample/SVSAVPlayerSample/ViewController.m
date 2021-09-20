//
//  ViewController.m
//  SVSAVPlayerSample
//
//  Created by glaubier on 17/01/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "ViewController.h"
#import "Constants.h"
#import "PlayerManager.h"

#import <SVSVideoKit/SVSVideoKit.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>

@interface ViewController () <SVSAdManagerDelegate, PlayerManagerDelegate>

//
@property (nonatomic, strong) PlayerManager *playerManager;
@property (nonatomic, assign) BOOL fullscreen;

// Smart Instream SDK properties
@property (nonatomic, strong) SVSAdManager *adManager;
@property (nonatomic, strong) SVSAVPlayerPlayHeadAdapter *playHeadAdapter;

@end

@implementation ViewController

#pragma mark - Object lifecycle

- (void)dealloc {
    // Reset Player
    self.playerManager = nil;
    
    // Reset SVSAdManager without calling a postroll
    if (self.adManager) {
        [self.adManager stopAndTriggerPostrollIfAny:NO];
    }
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup version label - not relevant for integration
    self.versionLabel.text = [NSString stringWithFormat:@"Smart - Instream SDK v%@", [SVSConfiguration sharedInstance].version];
                              
    // Status bar
    [self setNeedsStatusBarAppearanceUpdate];
    
    // Create the Ad manager
    [self createAdManager];
    
    // Create the content player
    [self createPlayerManager];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Note that requesting for ATT authorization must be made when the application is active (otherwise
    // the ATT popup will not be displayed and the ATT status will stay '.notDetermined').
    // You can for instance perform this request in the 'viewDidAppear' method or register for the
    // 'didBecomeActiveNotification' notification.
    [self requestTrackingAuthorization];
}


- (void)requestTrackingAuthorization {
    
    // Starting with iOS 14, you must ask the user for consent before being able to track it.
    // If you do not ask consent (or if the user decline), the SDK will not use the device IDFA.
    if (@available(iOS 14, *)) {
        // Check if the tracking authorization status is not determined…
        if (ATTrackingManager.trackingAuthorizationStatus == ATTrackingManagerAuthorizationStatusNotDetermined) {
            
            // Ask the user for tracking permission.
            //
            // Note:
            // In order to get a good user experience, choose the right time to display this
            // authorization request, and customize the autorization request description in the
            // app Info.plist file.
            [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
                    NSLog(@"[ATT] The tracking authorization has been granted by the user!");
                    
                    // The tracking authorization has been granted!
                    // The SDK will be able to use the device IDFA during ad calls.
                } else {
                    NSLog(@"[ATT] The tracking authorization is not granted!");
                    
                    // The tracking authorization has not been granted!
                    //
                    // The SDK will only uses a technical randomly generated ID that will not be
                    // shared cross apps and will be reset every 24 hours.
                    // This 'transient ID' will only be used for technical purposes (ad fraud
                    // detection, capping, …).
                    //
                    // You can disable it completely by using the following configuration flag:
                    // SASConfiguration.shared.transientIDEnabled = false
                }
            }];
        }
    }

}


- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        // It is called here only on iPhone, because the orientation do not affect fullscreen on iPad.
        // If we are in landscape on iPhone, we are in fullscreen. So we hide navigationBar
        [self.adManager contentPlayerIsFullscreen:size.height < size.width];
        [self updateFullscreen:size.height < size.width forceOrientation:NO];
    }
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self updateTopConstraintIfNeeded];
        [self.playerManager updateControlsFrames];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        // nothing to do
    }];
}

#pragma mark - Create Content Player

- (void)createPlayerManager {
    /////////////////////////////////////////////////////////////////////
    // Create the player manager.
    /////////////////////////////////////////////////////////////////////
    self.playerManager = [[PlayerManager alloc] initWithVideoContainerView:self.videoContainerView rootView:self.view delegate:self];
}

#pragma mark - PlayerManager Delegate

- (void)playerManagerIsReadyToPlay:(PlayerManager *)manager {
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // The player is ready to play and will play the content video soon.
    // We should bypass the normal process here and start the SVSAdManager instead.
    // It will try to play an ad, and then ask us to start the playback through <SVSAdManagerDelegate> callbacks.
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////
    if (![self.adManager isStarted]) {
        [self.playerManager pause];
        [self startAdManager];
    }
}


- (void)playerManagerDidReset:(PlayerManager *)manager {
    /////////////////////////////////////////////////////////////////////////////////////////////////
    // The user clicked on the reset button and the player will play its content from the beginning.
    // We should bypass the normal process here and called the replay method from the SVSAdManager
    // to display again all the ads.
    /////////////////////////////////////////////////////////////////////////////////////////////////
    [self.playerManager pause];
    [self.adManager replay];
}


- (void)playerManagerDidStop:(PlayerManager *)manager {
    ////////////////////////////////////////////////////////////////////////////
    // The user clicked on the stop button. We have to notify the SVSAdManager.
    ////////////////////////////////////////////////////////////////////////////
    [self.adManager stopAndTriggerPostrollIfAny:NO];
}


- (void)playerManager:(PlayerManager *)manager didUpdateFullscreenStatus:(BOOL)isFullscreen {
    //////////////////////////////////////////////////////////////////////////////////////////////
    // When the AVPlayer change its fullscreen status, we must let the SVSAdManager know about it
    // so it can adjust the UI of the AdPlayer view.
    //////////////////////////////////////////////////////////////////////////////////////////////
    [self updateFullscreen:isFullscreen forceOrientation:YES];
}

#pragma mark - Ad Player Control

- (void)createAdManager {
    /////////////////////////////////////////////////////////////////////////////////////////////
    // The SVSAdManager is the class responsible for performing AdCalls and displaying ads.
    // To initialize this object you will need:
    // - an SVSAdPlacement
    // - a delegate object, responding to <SVSAdManagerDelegate> protocol.
    // Optional objects can also be passed during initialization:
    // - SVSAdRules, to define advertising policy depending on content's duration. If nil, the SVSAdManager will create its own.
    // - SVSAdPlayerconfiguration, to modify the Ad player look and behavior. If nil, the SVSAdManager will create its own.
    // - SVSContentData, describing your content. If nil, the SVSAdManager will not use the data for targeting.
    //
    // Please refer to each initialization method for more information about these objects.
    /////////////////////////////////////////////////////////////////////////////////////////////
    
    // Ad placement, MANDATORY
    SVSAdPlacement *placement = [self instantiateAdPlacement];
    
    // Ad rules, OPTIONAL
    SVSAdRules *adRules = [self instantiateAdRules];
    
    // Ad player configuration, OPTIONAL
    SVSAdPlayerConfiguration *config = [self instantiateAdPlayerConfiguration];
    
    // Content data, OPTIONAL
    SVSContentData *datas = [self instantiateContentData];
    
    ////////////////////////////////////
    // Create the SVSAdManager instance
    ////////////////////////////////////
    self.adManager = [[SVSAdManager alloc] initWithDelegate:self placement:placement rules:adRules configuration:config contentData:datas];
    
    // Inform the SVSAdManager instance of the original state of the content player: not in fullscreen by default.
    [self.adManager contentPlayerIsFullscreen:NO];
}

- (void)startAdManager {
    // Create the playhead adapter - mandatory to monitor the content and trigger AdBreaks.
    self.playHeadAdapter = [self instantiatePlayheadAdapter];
    
    ///////////////////////////////////////////////////////////////////////////////////////
    // Start the SVSAdManager
    // Note that we pass the newly created playhead and the container view.
    // For AVPlayer, we pass the videoContainerView which already contains the player view.
    ///////////////////////////////////////////////////////////////////////////////////////
    [self.adManager startWithPlayHead:self.playHeadAdapter adContainerView:self.videoContainerView];
}

#pragma mark - smart Instream SDK - Object initialization

- (SVSAdPlacement *)instantiateAdPlacement {
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // SVSAdPlacement is mandatory to perform ad calls.
    // You cannot create an SVSAdManager without an SVSAdPlacement
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // Test ad placement, you can use it for debug
    //SVSAdPlacement *adPlacement = [SVSAdPlacement adPlacementForTestAd:SVSAdPlacementTestPrerollMidrollPostroll];
    
    // Create an SVSAdPlacement instance from your SiteID, PageID and FormatID.
    SVSAdPlacement *placement = [[SVSAdPlacement alloc] initWithSiteId:SmartInstreamSDK_SiteID pageId:SmartInstreamSDK_PageID formatId:SmartInstreamSDK_FormatID];
    
    // Optional: you can setup the custom targeting for your placement
    placement.globalKeywordsTargeting = SmartInstreamSDK_TGT; // Default targeting
    placement.preRollKeywordsTargeting = nil; // Preroll targeting
    placement.midRollKeywordsTargeting = nil; // Midroll targeting
    placement.postRollKeywordsTargeting = nil; // Postroll targeting
    
    return placement;
}


- (SVSAdRules *)instantiateAdRules {
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // SVSAdRule objects allow an advanced management of your advertising policy.
    // Please refer to the documentation for more information about these objects.
    // This object is optional:
    // SVSAdManager will use the default SVSAdRules set in SVSConfiguration if no SVSAdRules instance is
    // passed upon initialization.
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // Instantiate 3 SVSAdRuleData for Preroll, Midroll and Postroll
    SVSAdRuleData *prerollData = [SVSAdRuleData prerollDataWithInstances:1]; // Preroll with 1 ad
    SVSAdRuleData *postrollData = [SVSAdRuleData postrollDataWithInstances:1]; // Postroll with 1 ad
    SVSAdRuleData *midrollData = [SVSAdRuleData midrollDataWithInstances:1 percents:@[@50]]; // Midroll with 1 ad when 50% of the content's duration is reached.
    
    // Instantiate a SVSAdRule with preroll, midroll and postroll SVSAdRuleData
    // This SVSAdRule will cover any duration
    SVSAdRule *adRule = [SVSAdRule adRuleWithData:@[prerollData, midrollData, postrollData] durationMin:0 durationMax:-1];
    
    // Return an array of SVSAdRule
    return [SVSAdRules adRulesWithRules:@[adRule]];
}


- (SVSAdPlayerConfiguration *)instantiateAdPlayerConfiguration {
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // SVSAdPlayerConfiguration is responsible for modifying the look and behavior of the Ad player.
    // This object is optional:
    // SVSAdManager will use the default SVSAdPlayerConfiguration set in SVSConfiguration if no
    // SVSAdPlayerConfiguration instance is passed upon initialization.
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // Create a new SVSAdPlayerConfiguration
    SVSAdPlayerConfiguration *configuration = [[SVSAdPlayerConfiguration alloc] init];
    
    // Force skip delay of 5 seconds for any ad
    configuration.publisherOptions.forceSkipDelay = YES;
    configuration.publisherOptions.skipDelay = 5;
    
    // See API for more options…
    return configuration;
}


- (SVSContentData *)instantiateContentData {
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // SVSContentData provides information about your video content.
    // This object is optional.
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    SVSContentData *contentData = [[SVSContentData alloc] initWithContentID:@"contentID"
                                                               contentTitle:@"contentTitle"
                                                           videoContentType:@"videoContentType"
                                                       videoContentCategory:@"videoContentCategory"
                                                       videoContentDuration:@60
                                                          videoSeasonNumber:@1
                                                         videoEpisodeNumber:@2
                                                         videoContentRating:@"videoContentRating"
                                                          contentProviderID:@"contentProviderID"
                                                        contentProviderName:@"contentProviderName"
                                                  videoContentDistributorID:@"videoContentDistributorID"
                                                videoContentDistributorName:@"videoContentDistributorName"
                                                           videoContentTags:@[@"tag1", @"tag2"]
                                                          externalContentID:@"externalContentID"
                                                                 videoCMSID:@"externalContentID"];
    
    return contentData;
}


- (id <SVSContentPlayerPlayHead>)instantiatePlayheadAdapter {
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // To know when to display AdBreaks, the SVSAdManager needs to monitor your content, especially
    // - total duration
    // - current time
    // To be able to start the SVSAdManager, you need to create a playhead adapter, conforming to the
    // SVSContentPlayerPlayHead protocol.
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    SVSAVPlayerPlayHeadAdapter *playheadAdapter =  [[SVSAVPlayerPlayHeadAdapter alloc] initWithAVPlayer:self.playerManager.player unknownContentDuration:NO];;
    
    return playheadAdapter;
}

#pragma mark - Smart Ad Manager Delegate <SVSAdManagerDelegate>
#pragma mark - SVSAdManagerDelegate - Fail to start manager

- (void)adManager:(nonnull SVSAdManager *)adManager didFailToStartWithError:(nonnull NSError *)error {
    // Called when the SVSAdManager failed to start for some reason.
    // Most of the time it will be because your playheadAdapter is not ready…
    // See error description for more info.
    
    // You should start your content player because no ad will be played
    [self.playerManager play];
}

#pragma mark - SVSAdManagerDelegate - AdBreak informations

- (void)adManager:(nonnull SVSAdManager *)adManager didFailToStartAdBreak:(SVSAdBreakType)adBreakType error:(nonnull NSError *)error {
    // Called when an AdBreak did fail to start
}


- (void)adManager:(SVSAdManager *)adManager didStartAdBreak:(SVSAdBreakType)adBreakType {
    // Called when an AdBreak starts.
    
    // Here we hide the player controls to make sure they are not displayed over the ad.
    [self.playerManager showControls:NO];
}


- (void)adManager:(SVSAdManager *)adManager didFinishAdBreak:(SVSAdBreakType)adBreakType numberOfAds:(NSInteger)numberOfAdsPlayed duration:(NSTimeInterval)duration error:(NSError *)error {
    // Called when an AdBreak finishes.
    
    // Here we do not hide the players controls anymore.
    [self.playerManager showControls:YES];
}


- (void)adManagerDidRequestToPauseContentPlayer:(SVSAdManager *)adManager forAdBreak:(SVSAdBreakType)adBreakType {
    // Called when the SVSAdManager wants you to pause the content player. You should obey!
    [self.playerManager pause];
}


- (void)adManagerDidRequestToResumeContentPlayer:(SVSAdManager *)adManager afterAdBreak:(SVSAdBreakType)adBreakType {
    // Called when the SVSAdManager wants you tu play the content player. You should obey!
    [self.playerManager autoHideControls:NO];
    [self.playerManager play];
}


- (void)adManager:(SVSAdManager *)adManager didProgressToTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    // Called periodically to keep track of the SVSAdManager's playback status.
    // Might be interesting for you… or not.
}


- (void)adManagerDidRequestToEnterFullscreen:(SVSAdManager *)adManager {
    // Called when the enter fullscreen button of an Ad is clicked by the user.
    // Adapt your UI to properly react to this user action: you should resize your container view so it fits the whole screen.
    [self updateFullscreen:YES forceOrientation:YES];
    
    /*
     //////////////////////////////////////////////////
     // Note about fullscreen / exit fullscreen
     //////////////////////////////////////////////////
     
     For obvious reasons, SVSAdManager, will never force your application or your content player into fullscreen. It is your app, you decide what to do with it.
     However, if you allow the fullscreen / exit fullscreen buttons on the Ad Player Interface, SVSAdManager will ask its delegate to enter fullscreen through the adManagerDidRequestToEnterFullscreen method of SVSAdManagerDelegate protocol.
     You are responsible for responding to this event. The SVSAdPlayerView will always stick to the content player container view you passed when your started the SVSAdManager.
     This means that if you allow you content player to enter/exit fullscreen you have to modify the container view frame || bounds || superview || player state…
     Once you modified the container view size or status, gently let the SVSAdManager know about it by setting the new state of the content player through the contentPlayerIsFullscreen: method of SVSAdManager
     */
}

- (void)adManagerDidRequestToExitFullscreen:(SVSAdManager *)adManager {
    // Called when the exit fullscreen button of an Ad is clicked by the user.
    // Adapt your UI to properly react to this user action: you should resize your container view so it goes back to its original size.
    [self updateFullscreen:NO forceOrientation:YES];
}

- (void)adManager:(SVSAdManager *)adManager didGenerateCuePoints:(NSArray<SVSCuePoint *> *)cuePoints {
    // Called when cuepoints used for midroll ad break have been computed.
    // You can use this delegate method to display the ad break position in your content player UI…
}

#pragma mark - SVSAdManagerDelegate - Model presentation

- (UIViewController *)adManagerDidRequestPostClickPresentationViewController:(SVSAdManager *)adManager {
    // Called when the ad has been clicked and needs to open a modal.
    return self;
}

#pragma mark - Fullscreen

- (void)updateFullscreen:(BOOL)fullscreen forceOrientation:(BOOL)forceOrientation {
    ////////////////////////////////////////////////////////////////////
    // Handle all modification needed for the fullscreen status update.
    ////////////////////////////////////////////////////////////////////
    self.fullscreen = fullscreen;
    self.view.backgroundColor = fullscreen ? [UIColor blackColor] : [UIColor whiteColor];
    
    // Not all the fullscreen status updates come from the AVPlayerWrapper. So to make sure that
    // the AVPlayerWrapper update its own UI, we must notify it about the fullscreen status update.
    [self.playerManager updateFullscreenStatus:fullscreen];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        // On iPhone, the fullscreen status and the device orientation are linked.
        
        // If the player goes to fullscreen and device are in portrait, we set the orientation to landscape.
        if (fullscreen && forceOrientation) {
            [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
        
        } else if (!fullscreen) {
            // Then the player exit fullscreen we set the orientation to portrait.
            [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
        }
    } else {
        // It is called here if this is an iPad. For the iPhone, it is called in viewWillTransitionToSize delegate method.
        [self.adManager contentPlayerIsFullscreen:self.fullscreen];
        
        [self updateTopConstraintIfNeeded];
    }
    
}


- (void)updateTopConstraintIfNeeded {
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        return;
    }

    CGFloat calculatedVideoViewHeight = self.view.frame.size.width * 9 / 16;
    
    // If we are on fullscreen, the videoView must be centered.
    self.topConstraint.constant = self.fullscreen ? self.view.frame.size.height / 2 - calculatedVideoViewHeight / 2 : 0;
}

@end

//
//  ViewController.m
//  SVSBrightcoveSample
//
//  Created by glaubier on 17/01/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "ViewController.h"
#import "Constants.h"

#import <BrightcovePlayerSDK/BrightcovePlayerSDK.h>

#import <SVSVideoKit/SVSVideoKit.h>
#import "SVSBrightCovePlayheadAdapter.h"


#define BrightCove_PlaybackServicePolicyKey         @"BCpkADawqM1W-vUOMe6RSA3pA6Vw-VWUNn5rL0lzQabvrI63-VjS93gVUugDlmBpHIxP16X8TSe5LSKM415UHeMBmxl7pqcwVY_AZ4yKFwIpZPvXE34TpXEYYcmulxJQAOvHbv2dpfq-S_cm"
#define BrightCove_AccountID                        @"3636334163001"


@interface ViewController () <BCOVPlaybackControllerDelegate, BCOVPUIPlayerViewDelegate, SVSAdManagerDelegate>

// BrightCove Player
@property (nonatomic, strong) id <BCOVPlaybackController> playbackController;
@property (nonatomic, strong) BCOVPlaybackService *playbackService;
@property (nonatomic, strong) id <BCOVPlaybackSession> currentPlaybackSession;

// Keep a reference to brightcove's player view, this will be the container of the Ad Player view.
@property (nonatomic, strong) BCOVPUIPlayerView *playerView;

// Smart Instream SDK properties
@property (nonatomic, strong) SVSAdManager *adManager;
@property (nonatomic, strong) SVSBrightCovePlayheadAdapter *playheadAdapter;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup version label - not relevant for integration
    self.versionLabel.text = [NSString stringWithFormat:@"Smart - Instream SDK v%@", [SVSConfiguration sharedInstance].version];
    
    // Create the Ad Manager
    [self createAdManager];
    
    // Create the content player
    [self createBrightCovePlayer];
}


- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        // Fullscreen
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            if (size.height < size.width) {
                [self.playerView performScreenTransitionWithScreenMode:BCOVPUIScreenModeFull];
            } else {
                [self.playerView performScreenTransitionWithScreenMode:BCOVPUIScreenModeNormal];
            }
        }
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        //do nothing
    }];
}

#pragma mark - BrightCove Player

- (void)createBrightCovePlayer {
    // In this method we will create the content player using BrightCove SDK.
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Please refer to BrightCove documentation and samples for a more detailled integration
    //////////////////////////////////////////////////////////////////////////////////////////
    
    /////////////////////////////////////
    // Create a playback controller
    /////////////////////////////////////
    BCOVPlayerSDKManager *manager = [BCOVPlayerSDKManager sharedManager];
    self.playbackController = [manager createPlaybackController];
    self.playbackController.delegate = self;
    self.playbackController.autoAdvance = YES;
    self.playbackController.autoPlay = NO;
    
    /////////////////////////////////////
    // Create the playback service
    // responsible for retrieving videos
    /////////////////////////////////////
    self.playbackService = [[BCOVPlaybackService alloc] initWithAccountId:BrightCove_AccountID policyKey:BrightCove_PlaybackServicePolicyKey];
    
    /////////////////////////////////////
    // Create the UI for BrightCove Player
    /////////////////////////////////////
    
    // Player View Options
    BCOVPUIPlayerViewOptions *options = [[BCOVPUIPlayerViewOptions alloc] init];
    options.presentingViewController = self;
    options.hideControlsInterval = 30.0f;
    options.hideControlsAnimationDuration = 0.2f;
    
    // Control View.
    BCOVPUIBasicControlView *controlView = [BCOVPUIBasicControlView basicControlViewWithVODLayout];
    
    // Player View
    self.playerView = [[BCOVPUIPlayerView alloc] initWithPlaybackController:nil options:options controlsView:controlView];
    self.playerView.playbackController = self.playbackController;
    self.playerView.delegate = self;
    self.playerView.frame = self.videoView.bounds;
    self.playerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.videoView addSubview:self.playerView];
    
    /////////////////////////////////////
    // Request video content
    /////////////////////////////////////
    BCOVVideo *video = [BCOVVideo videoWithURL:[NSURL URLWithString:ContentVideoURL] deliveryMethod:kBCOVSourceDeliveryMP4];
    
    if (video) {
        [self.playbackController setVideos:@[video]];
    } else {
        NSLog(@"**** Error when retrieving content video - Just aborting session.");
    }
    
    //////////////////////////////////////////////////////////////////////////////////
    // Initialization of the SVSAdManager and playhead adapter will take place after
    // the playback controller informed us that the playback session is ready
    //////////////////////////////////////////////////////////////////////////////////
}

#pragma mark - BCOVPlaybackController and BCOVPUIPlayerView Delegate

- (void)playbackController:(id<BCOVPlaybackController>)controller didAdvanceToPlaybackSession:(id<BCOVPlaybackSession>)session {
    //////////////////////////////////////////////////////////////////////////////////
    // Playback session is now created.
    // Keep a reference to the session, it is needed create the playhead adapter
    //////////////////////////////////////////////////////////////////////////////////
    self.currentPlaybackSession = session;
}


- (void)playbackController:(id<BCOVPlaybackController>)controller playbackSession:(id<BCOVPlaybackSession>)session didChangeDuration:(NSTimeInterval)duration {
    //////////////////////////////////////////////////////////////////////////////////
    // Content loaded in the playback session. The duration is now known.
    // We could start the playback here, but instead we are going to start the SVSAdManager
    // which will try to play an ad, and then ask us to start the playback
    //////////////////////////////////////////////////////////////////////////////////
    if (duration > 0 && ![self.adManager isStarted]) {
        [self startAdManager];
    }
}


- (void)playerView:(BCOVPUIPlayerView *)playerView didTransitionToScreenMode:(BCOVPUIScreenMode)screenMode {
    //////////////////////////////////////////////////////////////////////////////////
    // When brightcove player change screen mode, we must let the SVSAdManager know
    // about it so it can adjust the UI of the AdPlayer view
    //////////////////////////////////////////////////////////////////////////////////
    [self.adManager contentPlayerIsFullscreen:(screenMode == BCOVPUIScreenModeFull)];
    if (screenMode != BCOVPUIScreenModeFull && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
    }
}

#pragma mark - Smart Instream SDK - Ad Manager

- (void)createAdManager {
    /////////////////////////////////////////////////////////////////////////////////////////
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
    
    // Ad Placement, MANDATORY
    SVSAdPlacement *adPlacement = [self instantiateAdPlacement];
    
    // Ad Rules, OPTIONAL
    SVSAdRules *adRules = [self instantiateAdRules];
    
    // Ad Player Configuration, OPTIONAL
    SVSAdPlayerConfiguration *adPlayerConfiguration = [self instantiateAdPlayerConfiguration];
    
    // Content Data, OPTIONAL
    SVSContentData *contentData = [self instantiateContentData];
    
    //////////////////////////////////////
    // Create the SVSAdManager instance
    //////////////////////////////////////
    self.adManager = [[SVSAdManager alloc] initWithDelegate:self placement:adPlacement rules:adRules configuration:adPlayerConfiguration contentData:contentData];
    
    // Inform the SVSAdManager instance of the original state of the content player: not in fullscreen by default.
    [self.adManager contentPlayerIsFullscreen:NO];
}

- (void)startAdManager {
    // Create the playhead adapter - mandatory to monitor the content and trigger AdBreaks.
    self.playheadAdapter = [self instantiatePlayheadAdapter];
    
    //////////////////////////////////////////////////////////////////////////////////
    // Start the SVSAdManager.
    // Note that we pass the newly created playhead adapter and the overlayView
    // of brightcove's playerView which is intended to display "overlay" over the content player
    // suits perfectly for our AdPlayerView
    //////////////////////////////////////////////////////////////////////////////////
    [self.adManager startWithPlayHead:self.playheadAdapter adContainerView:self.playerView.overlayView];
}

#pragma mark - Smart Instream SDK - Object initialization

- (SVSAdPlacement *)instantiateAdPlacement {
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    // SVSAdPlacement is mandatory to perform ad calls.
    // You cannot create an SVSAdManager without an SVSAdPlacement
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // Test ad placement, you can use it for debug
    //SVSAdPlacement *adPlacement = [SVSAdPlacement adPlacementForTestAd:SVSAdPlacementTestPrerollMidrollPostroll];
    
    // Create an SVSAdPlacement instance from your SiteID, PageID and FormatID
    SVSAdPlacement *adPlacement = [SVSAdPlacement adPlacementWithSiteId:SmartInstreamSDK_SiteID pageId:SmartInstreamSDK_PageID formatId:SmartInstreamSDK_FormatID];
    
    // Optional: you can setup the custom targeting for your placement
    adPlacement.globalKeywordsTargeting = SmartInstreamSDK_TGT; // Default targeting
    adPlacement.preRollKeywordsTargeting = nil; // Preroll targeting
    adPlacement.midRollKeywordsTargeting = nil; // Midroll targeting
    adPlacement.postRollKeywordsTargeting = nil; // Postroll targeting
    
    return adPlacement;
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
    SVSBrightCovePlayheadAdapter *playheadAdapter = [[SVSBrightCovePlayheadAdapter alloc] initWithBrightCovePlaybackSession:self.currentPlaybackSession unknownContentDuration:NO];
    
    return playheadAdapter;
}

#pragma mark - SVSAdManagerDelegate
#pragma mark - SVSAdManagerDelegate - Fail to start manager

- (void)adManager:(SVSAdManager *)adManager didFailToStartWithError:(NSError *)error {
    // Called when the SVSAdManager failed to start for some reason.
    // Most of the time it will be because your playheadAdapter is not ready…
    // See error description for more info.
    
    // You should start your content player because no ad will be played
    [self.playbackController play];
}

#pragma mark - SVSAdManagerDelegate - AdBreak informations

- (void)adManager:(SVSAdManager *)adManager didFailToStartAdBreak:(SVSAdBreakType)adBreakType error:(NSError *)error {
    // Called when an AdBreak did fail to start.
}


- (void)adManager:(SVSAdManager *)adManager didStartAdBreak:(SVSAdBreakType)adBreakType {
    // Called when an AdBreak starts.
}


- (void)adManager:(SVSAdManager *)adManager didFinishAdBreak:(SVSAdBreakType)adBreakType numberOfAds:(NSInteger)numberOfAdsPlayed duration:(NSTimeInterval)duration error:(nullable NSError *)error {
    // Called when an AdBreak finishes.
}

#pragma mark - SVSAdManagerDelegate - Content player control

- (void)adManagerDidRequestToPauseContentPlayer:(SVSAdManager *)adManager forAdBreak:(SVSAdBreakType)adBreakType {
    // Called when the SVSAdManager wants you to pause your content player. You should obey!
    [self.playbackController pause];
}


- (void)adManagerDidRequestToResumeContentPlayer:(SVSAdManager *)adManager afterAdBreak:(SVSAdBreakType)adBreakType {
    // Called when the SVSAdManager wants you to resume your content player. You should obey!
    [self.playbackController play];
}


- (void)adManager:(SVSAdManager *)adManager didProgressToTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    // Called periodically to keep track of the ad manager's playback status.
    // Might be interesting for you… or not.
}


- (void)adManagerDidRequestToEnterFullscreen:(SVSAdManager *)adManager {
    // Called when the enter fullscreen button of an Ad is clicked by the user.
    // Adapt your UI to properly react to this user action: you should resize your container view so it fits the whole screen.
    [self.playerView performScreenTransitionWithScreenMode:BCOVPUIScreenModeFull];
    
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
    [self.playerView performScreenTransitionWithScreenMode:BCOVPUIScreenModeNormal];
}

#pragma mark - SVSAdManagerDelegate - Modal presentation

- (UIViewController *)adManagerDidRequestPostClickPresentationViewController:(SVSAdManager *)adManager {
    // Called when the ad has been clicked and needs to open a modal.
    if (self.presentedViewController) {
        return self.presentedViewController;
    }
    return self;
}

@end


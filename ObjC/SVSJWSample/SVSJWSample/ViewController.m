//
//  ViewController.m
//  SVSJWSample
//
//  Created by glaubier on 17/01/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "ViewController.h"
#import "Constants.h"

#import <JWPlayer_iOS_SDK/JWPlayerController.h>

#import <SVSVideoKit/SVSVideoKit.h>
#import "SVSJWPlayerPlayheadAdapter.h"


@interface ViewController () <JWPlayerDelegate, SVSAdManagerDelegate>

// JWPlayer Player
@property (nonatomic, strong) JWPlayerController *player;

// Smart Instream SDK properties
@property (nonatomic, strong) SVSAdManager *adManager;
@property (nonatomic, strong) SVSJWPlayerPlayheadAdapter *playheadAdapter;

@end

@implementation ViewController

#pragma mark - ViewController Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup version label - not relevant for integration
    self.versionLabel.text = [NSString stringWithFormat:@"Smart - Instream SDK v%@", [SVSConfiguration sharedInstance].version];
    
    // Create the Ad manager
    [self createAdManager];
    
    // Create the content player
    [self createJWPlayer];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //////////////////////////////////
    // Configure the UI of the player
    //////////////////////////////////
    [self setupPlayerViewIfNeeded];
}

#pragma mark - JW Player

- (void)createJWPlayer {
    // In this method we will create the content player using JWPlayer SDK.
    
    ///////////////////////////////////////////////////////////////////////////////////////
    // Please refer to JWPlayer documentation and samples for a more detailled integration
    ///////////////////////////////////////////////////////////////////////////////////////
    
    ///////////////////////////
    // Create JW Player Config
    ///////////////////////////
    JWConfig *config = [JWConfig new];
    config.sources = @[[JWSource sourceWithFile:ContentVideoURL label:@"Video" isDefault:YES]];
    config.title = @"JWPlayer Sample";
    config.controls = YES;
    config.repeat = NO;
    config.skin = [JWSkinStyling new];

    /////////////////////////////
    // Create JWPlayerController
    /////////////////////////////
    self.player = [[JWPlayerController alloc] initWithConfig:config];
    self.player.delegate = self;
    self.player.displayLockScreenControls = NO;
    self.player.forceFullScreenOnLandscape = NO;
    self.player.forceLandscapeOnFullScreen = YES;
}


- (void)setupPlayerViewIfNeeded {
    if ([self.player.view isDescendantOfView:self.videoView]) {
        // If the videoView already contains the Player View, do nothing.
        return;
    }
    
    ////////////////////////////////
    // Configure the UI of JWPlayer
    ////////////////////////////////
    self.player.view.frame = self.videoView.bounds;
    self.player.view.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
    [self.videoView addSubview:self.player.view];
    
}

#pragma mark - JW Player Delegate <JWPlayerDelegate>

- (void)onBeforePlay {
    /////////////////////////////////////////////////////////////////////////////////////
    // The player is ready and will play the content video soon.
    // We should bypass the normal process here and start the SVSAdManager instead.
    // It will try to play an ad, and then ask us to start the playback through <SVSAdManagerDelegate> callbacks.
    /////////////////////////////////////////////////////////////////////////////////////
    if (![self.adManager isStarted]) {
        [self.player pause];
        [self startAdManager];
    }
}


- (void)onFullscreen:(JWEvent<JWFullscreenEvent> *)event {
    /////////////////////////////////////////////////////////////////////////////////
    // When JWPlayer change its fullscreen status, we must let the SVSAdManager know
    // about it so it can adjust the UI of the AdPlayer view.
    /////////////////////////////////////////////////////////////////////////////////
    [self.adManager contentPlayerIsFullscreen:event.fullscreen];
    
    // Automatically go to portrait when exiting fullscreen
    if (!event.fullscreen) {
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
    }
}

#pragma mark - Smart Ad Manager

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
    SVSAdPlacement *placement = [self instantiateAdPlacement];
    
    // Ad Rules, OPTIONAL
    SVSAdRules *adRules = [self instantiateAdRules];
    
    // Ad Player Configuration, OPTIONAL
    SVSAdPlayerConfiguration *config = [self instantiateAdPlayerConfiguration];
    
    // Content Data, OPTIONAL
    SVSContentData *datas = [self instantiateContentData];
    
    ////////////////////////////////////
    // Create the SVSAdManager instance
    ////////////////////////////////////
    self.adManager = [[SVSAdManager alloc] initWithDelegate:self placement:placement rules:adRules configuration:config contentData:datas];
    
    // Inform the SVSAdManager instance of the original state of the content player: not in fullscreen by default
    [self.adManager contentPlayerIsFullscreen:NO];
}


- (void)startAdManager {
    // Create the playhead adapter - mandatory to monitor the content and trigger AdBreaks.
    self.playheadAdapter = [self instantiatePlayheadAdapter];
    
    /////////////////////////////////////////////////////////////////////////////////////////////
    // Start the SVSAdManager.
    // Note that we pass the newly created playhead adapter and the container view.
    // For JWPlayer, the player view can be used to display "overlay" over the content player.
    /////////////////////////////////////////////////////////////////////////////////////////////
    [self.adManager startWithPlayHead:self.playheadAdapter adContainerView:[self playerAdContainerView]];
}

- (UIView*)playerAdContainerView {
    // Due to fullscreen states management changes between JWPlayer 2.x and 3.x,
    // we need to insert ad player in the JWPlaybackView and not in the JWAVContainer view
    
    // Get the subviews of the view
    NSArray *subviews = [self.player.view subviews];

    // Return if there are no subviews
    if ([subviews count] == 0) {
        NSLog(@"No subview found in JWPlayer.view"); // just in case
        return self.player.view;
    }
    
    return [subviews firstObject];
}

#pragma mark - Smart Instream SDK - Object initialization

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
                                                       videoContentCategory:@"videoContentCategory" videoContentDuration:@60
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
    SVSJWPlayerPlayheadAdapter *playheadAdapter = [[SVSJWPlayerPlayheadAdapter alloc] initWithJWPlayerController:self.player unknownContentDuration:NO];
    
    return playheadAdapter;
}

#pragma mark - Smart Ad Manager Delegate <SVSAdManagerDelegate>
#pragma mark - SVSAdManagerDelegate - Fail to start manager

- (void)adManager:(nonnull SVSAdManager *)adManager didFailToStartWithError:(nonnull NSError *)error {
    // Called when the SVSAdManager failed to start for some reason.
    // Most of the time it will be because your playheadAdapter is not ready…
    // See error description for more info.
}

#pragma mark - SVSAdManagerDelegate - AdBreak informations

- (void)adManager:(SVSAdManager *)adManager didFailToStartAdBreak:(SVSAdBreakType)adBreakType error:(NSError *)error {
    // Called when the SVSAdManager failed to start for some reason.
    // Most of the time it will be because your playheadAdapter is not ready…
    // See error description for more info.
    
    // You should start your content player because no ad will be played
    [self.player play];
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
    [self.player pause];
}


- (void)adManagerDidRequestToResumeContentPlayer:(SVSAdManager *)adManager afterAdBreak:(SVSAdBreakType)adBreakType {
    // Called when the SVSAdManager wants you to play your content player. You should obey!
    [self.player play];
}


- (void)adManager:(SVSAdManager *)adManager didProgressToTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    // Called periodically to keep track of the SVSAdManager's playback status.
    // Might be interesting for you… or not.
}


- (void)adManagerDidRequestToEnterFullscreen:(SVSAdManager *)adManager {
    // Called when the enter fullscreen button of an Ad is clicked by the user.
    // Adapt your UI to properly react to this user action: you should resize your container view so it fits the whole screen.
    self.player.fullscreen = YES;

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
    self.player.fullscreen = NO;
}

#pragma mark - SVSAdManagerDelegate - Modal presentation

- (UIViewController *)adManagerDidRequestPostClickPresentationViewController:(SVSAdManager *)adManager {
    // Called when the ad has been clicked and needs to open a modal.
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}

@end

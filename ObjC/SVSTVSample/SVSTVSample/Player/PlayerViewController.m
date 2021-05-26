//
//  PlayerViewController.m
//  TVAdPlayer
//
//  Created by Thomas Geley on 06/01/2018.
//  Copyright © 2018 Naxx Technologies. All rights reserved.
//

#import "PlayerViewController.h"
#import "Constants.h"

@interface PlayerViewController () <SVSAdManagerDelegate>

//
@property (nonatomic, strong) AVPlayerItem *playerItem;

// Smart Instream SDK properties
@property (nonatomic, strong) SVSAdManager *adManager;
@property (nonatomic, strong) SVSAVPlayerPlayHeadAdapter *playHeadAdapter;

@end

@implementation PlayerViewController

#pragma mark - Object Lifecycle

- (void)dealloc {
    // Reset SVSAdManager without calling a postroll
    if (self.adManager) {
        [self.adManager stopAndTriggerPostrollIfAny:NO];
    }
    
    // Unregister KVO
    [self unregisterStatusKVO];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    // Create the Ad manager
    [self createAdManager];
    
    // Create the content player
    [self createPlayer];
}

#pragma mark - AVPlayer

#pragma mark - AVPlayer - Lifecycle

- (void)createPlayer {
    // Create player item
    self.playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:ContentVideoURL]];
    
    // Create player from player item
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    // Register playerItem status KVO to know when to start the SVSAdManager
    [self registerStatusKVO];
}

#pragma mark - AVPlayer - PlayerItem KVO

- (void)registerStatusKVO {
    [self.playerItem addObserver:self forKeyPath:@"status" options:0 context:nil];
}


- (void)unregisterStatusKVO {
    [self.playerItem removeObserver:self forKeyPath:@"status"];
}


- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context {
    if (object == self.playerItem && [keyPath isEqualToString:@"status"]) {
        [self playerItemStatusDidChange:self.playerItem.status];
    }
}

#pragma mark - AVPlayer - PlayerItem KVO - Actions

- (void)playerItemStatusDidChange:(AVPlayerItemStatus)status {
    // When your AVPlayerItem is ready to play, you should start the SVSAdManager to deliver ads if its not been started already.
    if (status == AVPlayerStatusReadyToPlay && ![self.adManager isStarted]) {
        [self startAdManager];
    }
}

#pragma mark - Smart Instream SDK - Integration
#pragma mark - Smart Instream SDK - Integration - Ad Manager Initialization

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
    // Note that we pass the newly created playhead and the view of this controller.
    ///////////////////////////////////////////////////////////////////////////////////////
    [self.adManager startWithPlayHead:self.playHeadAdapter adContainerView:self.view];
}

#pragma mark - Smart Instream SDK - Integration - Objects initialization

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
    SVSAVPlayerPlayHeadAdapter *playheadAdapter =  [[SVSAVPlayerPlayHeadAdapter alloc] initWithAVPlayer:self.player unknownContentDuration:NO];;
    
    return playheadAdapter;
}

#pragma mark - Smart Instream SDK - <SVSAdManagerDelegate>
#pragma mark - Smart Instream SDK - <SVSAdManagerDelegate> - Fail to start manager

- (void)adManager:(nonnull SVSAdManager *)adManager didFailToStartWithError:(nonnull NSError *)error {
    // Called when the SVSAdManager failed to start for some reason.
    // Most of the time it will be because your playheadAdapter is not ready…
    // See error description for more info.
    
    // You should start your content player because no ad will be played
    [self.player play];
}

#pragma mark - Smart Instream SDK - <SVSAdManagerDelegate> - AdBreak informations

- (void)adManager:(nonnull SVSAdManager *)adManager didFailToStartAdBreak:(SVSAdBreakType)adBreakType error:(nonnull NSError *)error {
    // Called when an AdBreak did fail to start
}


- (void)adManager:(SVSAdManager *)adManager didStartAdBreak:(SVSAdBreakType)adBreakType {
    // Called when an AdBreak starts.
}


- (void)adManager:(SVSAdManager *)adManager didFinishAdBreak:(SVSAdBreakType)adBreakType numberOfAds:(NSInteger)numberOfAdsPlayed duration:(NSTimeInterval)duration error:(NSError *)error {
    // Called when an AdBreak finishes.
}


- (void)adManagerDidRequestToPauseContentPlayer:(SVSAdManager *)adManager forAdBreak:(SVSAdBreakType)adBreakType {
    // Called when the SVSAdManager wants you to pause the content player. You should obey!
    [self.player pause];
}


- (void)adManagerDidRequestToResumeContentPlayer:(SVSAdManager *)adManager afterAdBreak:(SVSAdBreakType)adBreakType {
    // Called when the SVSAdManager wants you tu play the content player. You should obey!
    [self.player play];
}


- (void)adManager:(SVSAdManager *)adManager didProgressToTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    // Called periodically to keep track of the SVSAdManager's playback status.
    // Might be interesting for you… or not.
}


- (void)adManagerDidRequestToEnterFullscreen:(SVSAdManager *)adManager {
    // Not relevant on TV Integrations
}


- (void)adManagerDidRequestToExitFullscreen:(SVSAdManager *)adManager {
    // Not relevant on TV Integrations
}


- (void)adManager:(SVSAdManager *)adManager didGenerateCuePoints:(NSArray<SVSCuePoint *> *)cuePoints {
    // Called when cuepoints used for midroll ad break have been computed.
    // You can use this delegate method to display the ad break position in your content player UI…
}

#pragma mark - Smart Instream SDK - <SVSAdManagerDelegate> - Modal presentation

- (UIViewController *)adManagerDidRequestPostClickPresentationViewController:(SVSAdManager *)adManager {
    // Called when the ad has been clicked and needs to open a modal.
    return self;
}

@end

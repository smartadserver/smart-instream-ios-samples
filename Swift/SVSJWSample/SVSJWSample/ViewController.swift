//
//  ViewController.swift
//  SVSJWSample
//
//  Created by Loïc GIRON DIT METAZ on 29/08/2019.
//  Copyright © 2019 Smart AdServer. All rights reserved.
//

import UIKit
import SVSVideoKit

class ViewController: UIViewController, SVSAdManagerDelegate, JWPlayerDelegate {
    
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var versionLabel: UILabel!
    
    private var adManager: SVSAdManager?
    private var playheadAdapter: SVSContentPlayerPlayHead?
    
    // MARK: - Object lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup version label - not relevant for integration
        versionLabel.text = "Smart - Instream SDK v\(SVSConfiguration.shared.version)"
        
        // Status bar
        setNeedsStatusBarAppearanceUpdate()
        
        // Create the ad manager
        createAdManager()
        
        // Configure the UI of the player if needed
        DispatchQueue.main.async { [unowned self] in
            self.setupPlayerViewIfNeeded()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Configure the UI of the player if needed
        setupPlayerViewIfNeeded()
    }
    
    // MARK: - JW Player
    
    private lazy var playerController: JWPlayerController = {
        // In this method we will create the content player using JWPlayer SDK.
        
        ///////////////////////////////////////////////////////////////////////////////////////
        // Please refer to JWPlayer documentation and samples for a more detailled integration
        ///////////////////////////////////////////////////////////////////////////////////////
        
        ///////////////////////////
        // Create JW Player Config
        ///////////////////////////
        let config = JWConfig()
        config.sources = [JWSource(file: Constants.contentVideoURL, label: "Video", isDefault: true)]
        //config.sources = [JWSource(file: Constants.contentVideoURL, label: "Video", isDefault: true)!]
        config.title = "JWPlayer Sample"
        config.controls = true
        config.repeat = false
        config.skin = JWSkinStyling.init()
        
        /////////////////////////////
        // Create JWPlayerController
        /////////////////////////////
        let playerController = JWPlayerController(config: config)!
        playerController.delegate = self
        playerController.displayLockScreenControls = false
        playerController.forceFullScreenOnLandscape = false
        playerController.forceLandscapeOnFullScreen = true
        
        return playerController
    }()
    
    func setupPlayerViewIfNeeded() {
        if let playerView = playerController.view {
            guard !(playerView.isDescendant(of: videoContainerView)) else { return }
            playerView.frame = videoContainerView.bounds
            playerView.autoresizingMask = [.flexibleBottomMargin, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleWidth]
            videoContainerView.addSubview(playerView)
        }
    }
    
    // MARK: - Ad Manager instantiation
    
    func createAdManager() {
        /////////////////////////////////////////////////////////////////////////////////////////////
        // The SVSAdManager is the class responsible for performing ad calls and displaying ads.
        //
        // To initialize this object you will need:
        // - an SVSAdPlacement
        // - a delegate object, responding to SVSAdManagerDelegate protocol.
        //
        // Optional objects can also be passed during initialization:
        // - SVSAdRules, to define advertising policy depending on content's duration. If nil, the SVSAdManager will create its own.
        // - SVSAdPlayerconfiguration, to modify the Ad player look and behavior. If nil, the SVSAdManager will create its own.
        // - SVSContentData, describing your content. If nil, the SVSAdManager will not use the data for targeting.
        //
        // Please refer to each initialization method for more information about these objects.
        /////////////////////////////////////////////////////////////////////////////////////////////
        
        // Ad placement, MANDATORY
        let placement = instantiateAdPlacement()
        
        // Ad rules, OPTIONAL
        let adRules = instantiateAdRules()
        
        // Ad player configuration, OPTIONAL
        let config = instantiateAdPlayerConfiguration()
        
        // Content data, OPTIONAL
        let contentData = instantiateContentData()
        
        // Create the SVSAdManager instance
        adManager = SVSAdManager(delegate: self, placement: placement, rules: adRules, configuration: config, contentData: contentData)
        
        // Inform the SVSAdManager instance of the original state of the content player: not in fullscreen by default.
        adManager?.contentPlayerIsFullscreen(false)
    }
    
    func startAdManager() {
        guard let adManager = adManager else { return }
        
        // Create the playhead adapter - mandatory to monitor the content and trigger AdBreaks.
        playheadAdapter = instantiatePlayheadAdapter(playerController: playerController)
        
        ///////////////////////////////////////////////////////////////////////////////////////
        // Start the SVSAdManager
        // Note that we pass the newly created playhead and the container view.
        // For AVPlayer, we pass the videoContainerView which already contains the player view.
        ///////////////////////////////////////////////////////////////////////////////////////
        adManager.start(with: playheadAdapter!, adContainerView: playerAdContainerView())
    }
    
    func playerAdContainerView() -> UIView {
        // Due to fullscreen states management changes between JWPlayer 2.x and 3.x,
        // we need to insert ad player in the JWPlaybackView and not in the JWAVContainer view
        
        if let firstSubview = playerController.view?.subviews.first {
            return firstSubview
        }
        return playerController.view! // just in case
    }
    
    func instantiatePlayheadAdapter(playerController: JWPlayerController) -> SVSContentPlayerPlayHead {
        ////////////////////////////////////////////////////////////////////////////////////////////////////
        // To know when to display AdBreaks, the SVSAdManager needs to monitor your content, especially
        // - total duration
        // - current time
        // To be able to start the SVSAdManager, you need to create a playhead adapter, conforming to the
        // SVSContentPlayerPlayHead protocol.
        ////////////////////////////////////////////////////////////////////////////////////////////////////
        return JWPlayerPlayheadAdapter(playerController: playerController, infiniteDuration: false)
    }
    
    func instantiateAdPlacement() -> SVSAdPlacement {
        ////////////////////////////////////////////////////////////////////////////////////////////////////
        // SVSAdPlacement is mandatory to perform ad calls.
        // You cannot create an SVSAdManager without an SVSAdPlacement
        ////////////////////////////////////////////////////////////////////////////////////////////////////
        
        // Test ad placement, you can use it for debug
        // let placement = SVSAdPlacement(forTestAd: .prerollMidrollPostroll)
        
        // Create an SVSAdPlacement instance from your SiteID, PageID and FormatID.
        let placement = SVSAdPlacement(siteId: Constants.siteID, pageId: Constants.pageID, formatId: Constants.formatID)
        
        // Optional: you can setup the custom targeting for your placement
        placement.globalKeywordsTargeting = Constants.targeting // Default targeting
        placement.preRollKeywordsTargeting = nil // Preroll targeting
        placement.midRollKeywordsTargeting = nil // Midroll targeting
        placement.postRollKeywordsTargeting = nil // Postroll targeting
        
        return placement
    }
    
    func instantiateAdRules() -> SVSAdRules {
        ////////////////////////////////////////////////////////////////////////////////////////////////////
        // SVSAdRule objects allow an advanced management of your advertising policy.
        // Please refer to the documentation for more information about these objects.
        //
        // This object is optional:
        // SVSAdManager will use the default SVSAdRules set in SVSConfiguration if no SVSAdRules instance is
        // passed upon initialization.
        ////////////////////////////////////////////////////////////////////////////////////////////////////
        
        // Instantiate 3 SVSAdRuleData for preroll, midroll and postroll
        let preRollData = SVSAdRuleData.prerollData(withInstances: 1)! // Preroll with 1 ad
        let postRollData = SVSAdRuleData.postrollData(withInstances: 1)! // Postroll with 1 ad
        let midRollData = SVSAdRuleData.midrollData(withInstances: 1, percents: [50])! // Midroll with 1 ad when 50% of the content's duration is reached.
        
        // Instantiate a SVSAdRule with preroll, midroll and postroll SVSAdRuleData
        // This SVSAdRule will cover any duration
        let adRule = SVSAdRule(data: [preRollData, midRollData, postRollData], durationMin: 0, durationMax: -1)!
        
        // Return an array of SVSAdRule
        return SVSAdRules(rules: [adRule])!
    }
    
    func instantiateAdPlayerConfiguration() -> SVSAdPlayerConfiguration {
        ////////////////////////////////////////////////////////////////////////////////////////////////////
        // SVSAdPlayerConfiguration is responsible for modifying the look and behavior of the Ad player.
        //
        // This object is optional:
        // SVSAdManager will use the default SVSAdPlayerConfiguration set in SVSConfiguration if no
        // SVSAdPlayerConfiguration instance is passed upon initialization.
        ////////////////////////////////////////////////////////////////////////////////////////////////////
        
        // Create a new SVSAdPlayerConfiguration
        let configuration = SVSAdPlayerConfiguration()
        
        // Force skip delay of 5 seconds for any ad
        configuration.publisherOptions.forceSkipDelay = true
        configuration.publisherOptions.skipDelay = 5
        
        // See the API documentation for more options…
        return configuration
    }
    
    func instantiateContentData() -> SVSContentData {
        ////////////////////////////////////////////////////////////////////////////////////////////////////
        // SVSContentData provides information about your video content.
        // This object is optional.
        ////////////////////////////////////////////////////////////////////////////////////////////////////
        
        return SVSContentData(contentID: "contentID",
                              contentTitle: "contentTitle",
                              videoContentType: "videoContentType",
                              videoContentCategory: "videoContentCategory",
                              videoContentDuration: 60,
                              videoSeasonNumber: 1,
                              videoEpisodeNumber: 2,
                              videoContentRating: "videoContentRating",
                              contentProviderID: "contentProviderID",
                              contentProviderName: "contentProviderName",
                              videoContentDistributorID: "videoContentDistributorID",
                              videoContentDistributorName: "videoContentDistributorName",
                              videoContentTags: ["tag1", "tag2"],
                              externalContentID: "externalContentID",
                              videoCMSID: "externalContentID")
    }
    
    // MARK: - Ad Manager Delegate
    
    func adManager(_ adManager: SVSAdManager, didFailToStartWithError error: Error) {
        // Called when the SVSAdManager failed to start for some reason.
        // Most of the time it will be because your playheadAdapter is not ready…
        // See error description for more info.
        
        // You should start your content player because no ad will be played
        playerController.play()
    }
    
    func adManager(_ adManager: SVSAdManager, didFailToStart adBreakType: SVSAdBreakType, error: Error) {
        // Called when the SVSAdManager failed to start for some reason.
        // Most of the time it will be because your playheadAdapter is not ready…
        // See error description for more info.
        
        // You should start your content player because no ad will be played
        playerController.play()
    }
    
    func adManager(_ adManager: SVSAdManager, didStart adBreakType: SVSAdBreakType) {
        // Called when an AdBreak starts.
    }
    
    func adManager(_ adManager: SVSAdManager, didFinish adBreakType: SVSAdBreakType, numberOfAds numberOfAdsPlayed: Int, duration: TimeInterval, error: Error?) {
        // Called when an AdBreak finishes.
    }
    
    func adManagerDidRequest(toPauseContentPlayer adManager: SVSAdManager, for adBreakType: SVSAdBreakType) {
        // Called when the SVSAdManager wants you to pause the content player. You should obey!
        playerController.pause()
    }
    
    func adManagerDidRequest(toResumeContentPlayer adManager: SVSAdManager, after adBreakType: SVSAdBreakType) {
        // Called when the SVSAdManager wants you tu play the content player. You should obey!
        playerController.play()
    }
    
    func adManager(_ adManager: SVSAdManager, didProgressToTime currentTime: TimeInterval, totalTime: TimeInterval) {
        // Called periodically to keep track of the SVSAdManager's playback status.
        // Might be interesting for you… or not.
    }
    
    func adManagerDidRequest(toEnterFullscreen adManager: SVSAdManager) {
        // Called when the enter fullscreen button of an Ad is clicked by the user.
        // Adapt your UI to properly react to this user action: you should resize your container view so it fits the whole screen.
        playerController.fullscreen = true
        
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
    
    func adManagerDidRequest(toExitFullscreen adManager: SVSAdManager) {
        // Called when the exit fullscreen button of an Ad is clicked by the user.
        // Adapt your UI to properly react to this user action: you should resize your container view so it goes back to its original size.
        playerController.fullscreen = false

    }
    
    func adManagerDidRequestPostClickPresentationViewController(_ adManager: SVSAdManager) -> UIViewController {
        return self
    }
    
    func adManager(_ adManager: SVSAdManager, didGenerate cuePoints: [SVSCuePoint]) {
        // Called when cuepoints used for midroll ad break have been computed.
        // You can use this delegate method to display the ad break position in your content player UI…
    }
    
    // MARK: - JW Player Delegate
    
    func onBeforePlay() {
        /////////////////////////////////////////////////////////////////////////////////////
        // The player is ready and will play the content video soon.
        // We should bypass the normal process here and start the SVSAdManager instead.
        // It will try to play an ad, and then ask us to start the playback through <SVSAdManagerDelegate> callbacks.
        /////////////////////////////////////////////////////////////////////////////////////
        if let adManager = adManager, !adManager.isStarted() {
            playerController.pause()
            startAdManager()
        }
    }
    
    func onFullscreen(status: Bool) {
        /////////////////////////////////////////////////////////////////////////////////
        // When JWPlayer change its fullscreen status, we must let the SVSAdManager know
        // about it so it can adjust the UI of the AdPlayer view.
        /////////////////////////////////////////////////////////////////////////////////
        adManager?.contentPlayerIsFullscreen(status)
        
        // Automatically go to portrait when exiting fullscreen
        if !status {
            UIDevice.current.setValue(NSNumber(value: UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }
    }

}

//
//  ViewController.swift
//  SVSAVPlayerSample
//
//  Created by Loïc GIRON DIT METAZ on 28/08/2019.
//  Copyright © 2019 Smart AdServer. All rights reserved.
//

import UIKit
import SVSVideoKit
import AVFoundation

class ViewController: UIViewController, SVSAdManagerDelegate, PlayerManagerDelegate {

    @IBOutlet weak var videoContainerView: VideoContainerView!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    private var adManager: SVSAdManager?
    private var playheadAdapter: SVSContentPlayerPlayHead?
    
    private var playerManager: PlayerManager?
    
    // MARK: - Object lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup version label - not relevant for integration
        versionLabel.text = "Smart - Instream SDK v\(SVSConfiguration.shared.version)"
        
        // Status bar
        setNeedsStatusBarAppearanceUpdate()
        
        // Create the ad manager
        createAdManager()
        
        // Create the content player
        createPlayerManager()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if UI_USER_INTERFACE_IDIOM() == .phone {
            // It is called here only on iPhone, because the orientation do not affect fullscreen on iPad.
            // If we are in landscape on iPhone, we are in fullscreen. So we hide navigationBar
            let fullscreen = size.height < size.width
            adManager?.contentPlayerIsFullscreen(fullscreen)
            updateFullscreen(fullscreen: fullscreen, forceOrientation: false)
        }
        
        coordinator.animate(alongsideTransition: { [unowned self] (context) in
            self.updateTopConstraintsIfNeeded()
            self.playerManager?.updateControlsFrames()
        }) { (context) in
            // nothing to do
        }
    }
    
    // MARK: - Create Content Player
    
    func createPlayerManager() {
        playerManager = PlayerManager(videoContainerView: videoContainerView, rootView: view, delegate: self)
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
        guard let player = playerManager?.player,
            let adManager = adManager else { return }
        
        // Create the playhead adapter - mandatory to monitor the content and trigger AdBreaks.
        playheadAdapter = instantiatePlayheadAdapter(player: player)
        
        ///////////////////////////////////////////////////////////////////////////////////////
        // Start the SVSAdManager
        // Note that we pass the newly created playhead and the container view.
        // For AVPlayer, we pass the videoContainerView which already contains the player view.
        ///////////////////////////////////////////////////////////////////////////////////////
        adManager.start(with: playheadAdapter!, adContainerView: videoContainerView)
    }
    
    func instantiatePlayheadAdapter(player: AVPlayer) -> SVSContentPlayerPlayHead {
        ////////////////////////////////////////////////////////////////////////////////////////////////////
        // To know when to display AdBreaks, the SVSAdManager needs to monitor your content, especially
        // - total duration
        // - current time
        // To be able to start the SVSAdManager, you need to create a playhead adapter, conforming to the
        // SVSContentPlayerPlayHead protocol.
        ////////////////////////////////////////////////////////////////////////////////////////////////////
        return SVSAVPlayerPlayHeadAdapter(avPlayer: player, unknownContentDuration: false)
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
        playerManager?.play()
    }
    
    func adManager(_ adManager: SVSAdManager, didFailToStart adBreakType: SVSAdBreakType, error: Error) {
        // Called when the SVSAdManager failed to start for some reason.
        // Most of the time it will be because your playheadAdapter is not ready…
        // See error description for more info.
        
        // You should start your content player because no ad will be played
        playerManager?.play()
    }
    
    func adManager(_ adManager: SVSAdManager, didStart adBreakType: SVSAdBreakType) {
        // Called when an AdBreak starts.
        
        // Here we hide the player controls to make sure they are not displayed over the ad.
        playerManager?.showControl(false)
    }
    
    func adManager(_ adManager: SVSAdManager, didFinish adBreakType: SVSAdBreakType, numberOfAds numberOfAdsPlayed: Int, duration: TimeInterval, error: Error?) {
        // Called when an AdBreak finishes.
        
        // Here we do not hide the players controls anymore.
        playerManager?.showControl(true)
    }
    
    func adManagerDidRequest(toPauseContentPlayer adManager: SVSAdManager, for adBreakType: SVSAdBreakType) {
        // Called when the SVSAdManager wants you to pause the content player. You should obey!
        playerManager?.pause()
    }
    
    func adManagerDidRequest(toResumeContentPlayer adManager: SVSAdManager, after adBreakType: SVSAdBreakType) {
        // Called when the SVSAdManager wants you tu play the content player. You should obey!
        playerManager?.autoHideControls(hide: false)
        playerManager?.play()
    }
    
    func adManager(_ adManager: SVSAdManager, didProgressToTime currentTime: TimeInterval, totalTime: TimeInterval) {
        // Called periodically to keep track of the SVSAdManager's playback status.
        // Might be interesting for you… or not.
    }
    
    func adManagerDidRequest(toEnterFullscreen adManager: SVSAdManager) {
        // Called when the enter fullscreen button of an Ad is clicked by the user.
        // Adapt your UI to properly react to this user action: you should resize your container view so it fits the whole screen.
        updateFullscreen(fullscreen: true, forceOrientation: true)
        
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
        updateFullscreen(fullscreen: false, forceOrientation: true)
    }
    
    func adManagerDidRequestPostClickPresentationViewController(_ adManager: SVSAdManager) -> UIViewController {
        return self
    }
    
    // MARK: - PlayerManager delegate
    
    func playerManager(playerManager: PlayerManager, didUpdateFullscreenStatus isFullscreen: Bool) {
        //////////////////////////////////////////////////////////////////////////////////////////////
        // When the AVPlayer change its fullscreen status, we must let the SVSAdManager know about it
        // so it can adjust the UI of the AdPlayer view.
        //////////////////////////////////////////////////////////////////////////////////////////////
        updateFullscreen(fullscreen: isFullscreen, forceOrientation: true)
    }
    
    func playerManagerIsReadyToPlay(playerManager: PlayerManager) {
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // The player is ready to play and will play the content video soon.
        // We should bypass the normal process here and start the SVSAdManager instead.
        // It will try to play an ad, and then ask us to start the playback through <SVSAdManagerDelegate> callbacks.
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////
        if let adManager = adManager, !adManager.isStarted() {
            playerManager.pause()
            startAdManager()
        }
    }
    
    func playerManagerDidReset(playerManager: PlayerManager) {
        /////////////////////////////////////////////////////////////////////////////////////////////////
        // The user clicked on the reset button and the player will play its content from the beginning.
        // We should bypass the normal process here and called the replay method from the SVSAdManager
        // to display again all the ads.
        /////////////////////////////////////////////////////////////////////////////////////////////////
        playerManager.pause()
        adManager?.replay()
    }
    
    func playerManagerDidStop(playerManager: PlayerManager) {
        ////////////////////////////////////////////////////////////////////////////
        // The user clicked on the stop button. We have to notify the SVSAdManager.
        ////////////////////////////////////////////////////////////////////////////
        adManager?.stopAndTriggerPostrollIfAny(false)
    }
    
    // MARK: - Fullscreen
    
    private var fullscreen: Bool = false
    
    func updateFullscreen(fullscreen: Bool, forceOrientation: Bool) {
        ////////////////////////////////////////////////////////////////////
        // Handle all modification needed for the fullscreen status update.
        ////////////////////////////////////////////////////////////////////
        self.fullscreen = fullscreen
        view.backgroundColor = fullscreen ? UIColor.black : UIColor.white
        
        // Not all the fullscreen status updates come from the AVPlayerWrapper. So to make sure that
        // the AVPlayerWrapper update its own UI, we must notify it about the fullscreen status update.
        playerManager?.updateFullscreenStatus(isFullscreen: fullscreen)

        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            // On iPhone, the fullscreen status and the device orientation are linked.

            // If the player goes to fullscreen and device are in portrait, we set the orientation to landscape.
            if fullscreen && forceOrientation {
                UIDevice.current.setValue(NSNumber(value: UIInterfaceOrientation.landscapeRight.rawValue), forKey: "orientation")
            } else if !fullscreen {
                // Then the player exit fullscreen we set the orientation to portrait.
                UIDevice.current.setValue(NSNumber(value: UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
            }
        } else {
            // It is called here if this is an iPad. For the iPhone, it is called in viewWillTransitionToSize delegate method.
            adManager?.contentPlayerIsFullscreen(fullscreen)

            updateTopConstraintsIfNeeded()
        }
    }
    
    private func updateTopConstraintsIfNeeded() {
        guard UI_USER_INTERFACE_IDIOM() == .pad else { return }
        
        let calculatedVideoViewHeight: CGFloat = view.frame.size.width * 9 / 16
        
        // If we are on fullscreen, the videoView must be centered.
        topConstraint.constant = fullscreen ? view.frame.size.height / 2 - calculatedVideoViewHeight / 2 : 0
    }

}

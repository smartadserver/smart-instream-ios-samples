//
//  ViewController.swift
//  SVSAVPlayerSample
//
//  Created by Julien Gomez on 12/01/2023.
//  Copyright © 2023 Equativ. All rights reserved.
//

import UIKit
import AppTrackingTransparency
import AVFoundation
import SVSVideoKit

/////////////////////////////////////////////////////////////////////////////////////////////
// The ViewController is the class where you will find how to integrate Equativ Instream SDK, and especially the SVSAdManager instance.
/////////////////////////////////////////////////////////////////////////////////////////////

class ViewController: UIViewController, SVSAdManagerDelegate, PlayerViewControllerDelegate {
    

    @IBOutlet weak var playerContainerView: UIView!
    @IBOutlet weak var versionLabel: UILabel!
  
    private var playerViewController: PlayerViewController!
    private var adManager: SVSAdManager?
    private var playheadAdapter: SVSContentPlayerPlayHead?

    
    private var fullscreenState:Bool = false
    
    private var collapsedSizeConstraint: NSLayoutConstraint!
    private var expandedSizeConstraint: NSLayoutConstraint!
    private var collapsedTopConstraint: NSLayoutConstraint!
    private var expandedTopConstraint: NSLayoutConstraint!

    // MARK: - Object lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup version label - not relevant for integration
        versionLabel.text = "Equativ - Instream SDK v\(SVSConfiguration.shared.version)"
        
        // Create constraints for both inline / fullscreen modes of the player
        setupUIConstraints();
        
        // Create the ad manager
        createAdManager()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Note that requesting for ATT authorization must be made when the application is active (otherwise
        // the ATT popup will not be displayed and the ATT status will stay '.notDetermined').
        // You can for instance perform this request in the 'viewDidAppear' method or register for the
        // 'didBecomeActiveNotification' notification.
        requestTrackingAuthorization()
    }
    
    // MARK: - ATT
    
    func requestTrackingAuthorization() {
        // Starting with iOS 14, you must ask the user for consent before being able to track it.
        // If you do not ask consent (or if the user decline), the SDK will not use the device IDFA.
        if #available(iOS 14.0, *) {
            // Check if the tracking authorization status is not determined…
            if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
                
                // Ask the user for tracking permission.
                //
                // Note:
                // In order to get a good user experience, choose the right time to display this
                // authorization request, and customize the autorization request description in the
                // app Info.plist file.
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                    if status == .authorized {
                        NSLog("[ATT] The tracking authorization has been granted by the user!")
                        
                        // The tracking authorization has been granted!
                        // The SDK will be able to use the device IDFA during ad calls.
                    } else {
                        NSLog("[ATT] The tracking authorization is not granted!")
                        
                        // The tracking authorization has not been granted!
                        // The SDK will not track the user.
                    }
                })
            }
        }
    }
    
    // MARK: - Inline / Fullscreen constraints & View Controller supported orientations
    
    func setupUIConstraints() {
        NSLayoutConstraint.activate([
            playerContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)

        ])

        collapsedSizeConstraint = playerContainerView.heightAnchor.constraint(equalTo: playerContainerView.widthAnchor, multiplier: 9/16)
        expandedSizeConstraint = playerContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)

        let guide = view.safeAreaLayoutGuide

        collapsedTopConstraint = playerContainerView.topAnchor.constraint(equalTo: guide.topAnchor)
        expandedTopConstraint = playerContainerView.topAnchor.constraint(equalTo: view.topAnchor)
        
        collapsedSizeConstraint.isActive = !fullscreenState
        expandedSizeConstraint.isActive = fullscreenState
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return fullscreenState ? .allButUpsideDown : .portrait
    }
    
    func updatePlayerConstraints(fullscreenState:Bool) {
        self.fullscreenState = fullscreenState
        collapsedSizeConstraint?.isActive = !fullscreenState
        collapsedTopConstraint?.isActive = !fullscreenState
        expandedSizeConstraint?.isActive = fullscreenState
        expandedTopConstraint?.isActive = fullscreenState
        view.layoutIfNeeded()
        ViewController.attemptRotationToDeviceOrientation()
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
        guard let player = playerViewController?.player,
            let adManager = adManager else { return }
        
        // Create the playhead adapter - mandatory to monitor the content and trigger AdBreaks.
        playheadAdapter = instantiatePlayheadAdapter(player: player)
        
        ///////////////////////////////////////////////////////////////////////////////////////
        // Start the SVSAdManager
        // Note that we pass the newly created playhead and the container view.
        // For AVPlayer, we pass the videoContainerView which already contains the player view.
        ///////////////////////////////////////////////////////////////////////////////////////
        adManager.start(with: playheadAdapter!, adContainerView: playerViewController.adContainerView)
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
    }
    
    func adManager(_ adManager: SVSAdManager, didFailToStart adBreakType: SVSAdBreakType, error: Error) {
        // Called when the SVSAdManager failed to start for some reason.
        // Most of the time it will be because your playheadAdapter is not ready…
        // See error description for more info.
    }
    
    func adManager(_ adManager: SVSAdManager, didStart adBreakType: SVSAdBreakType) {
        // Called when an AdBreak starts.
        
        // Show the ad container view
        playerViewController?.adContainerView.isHidden = false
    }
    
    func adManager(_ adManager: SVSAdManager, didFinish adBreakType: SVSAdBreakType, numberOfAds numberOfAdsPlayed: Int, duration: TimeInterval, error: Error?) {
        // Called when an AdBreak finishes.
        
        // Here we do not hide the players controls anymore.
        playerViewController?.showControls(true)
        
        // Hide the ad container view
        playerViewController?.adContainerView.isHidden = true
    }
    
    func adManagerDidRequest(toPauseContentPlayer adManager: SVSAdManager, for adBreakType: SVSAdBreakType) {
        // Called when the SVSAdManager wants you to pause the content player.
        playerViewController?.pause()
    }
    
    func adManagerDidRequest(toResumeContentPlayer adManager: SVSAdManager, after adBreakType: SVSAdBreakType) {
        // Called when the SVSAdManager wants you to play the content player.
        playerViewController?.play()
    }
    
    func adManager(_ adManager: SVSAdManager, didProgressToTime currentTime: TimeInterval, totalTime: TimeInterval) {
        // Called periodically to keep track of the SVSAdManager's playback status.
        // Might be interesting for you… or not.
    }
    
    func adManagerDidRequest(toEnterFullscreen adManager: SVSAdManager) {
        // Called when the enter fullscreen button of an Ad is clicked by the user.
        // Adapt your UI to properly react to this user action: you should resize your container view so it fits the whole screen.
        playerViewController.setFullscreen(true)
        updatePlayerConstraints(fullscreenState: true)
        
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
        
        // Updating the content player state
        adManager.contentPlayerIsFullscreen(true)
    }
    
    func adManagerDidRequest(toExitFullscreen adManager: SVSAdManager) {
        // Called when the exit fullscreen button of an Ad is clicked by the user.
        // Adapt your UI to properly react to this user action: you should resize your container view so it goes back to its original size.
        playerViewController.setFullscreen(false)
        updatePlayerConstraints(fullscreenState: false)
        
        // Updating the content player state
        adManager.contentPlayerIsFullscreen(false)
    }
    
    func adManagerDidRequestPostClickPresentationViewController(_ adManager: SVSAdManager) -> UIViewController {
        return self
    }
    
    func adManager(_ adManager: SVSAdManager, didGenerate cuePoints: [SVSCuePoint]) {
        // Called when cuepoints used for midroll ad break have been computed.
        // You can use this delegate method to display the ad break position in your content player UI…
    }
    
    
    // MARK: - Player View Controller Delegate

    func playerViewControllerIsReadyToPlay(videoPlayerViewController: PlayerViewController) {
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // The player is ready to play and will play the content video soon.
        // We should bypass the normal process here and start the SVSAdManager instead.
        // It will try to play an ad, and then ask us to start the playback through <SVSAdManagerDelegate> callbacks.
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////
        if let adManager = adManager, !adManager.isStarted() {
            videoPlayerViewController.player.pause()
            startAdManager()
        }
    }
    
    func playerViewControllerDidRequest(toEnterFullscreen videoPlayerViewController: PlayerViewController) {
        //////////////////////////////////////////////////////////////////////////////////////////////
        // When the AVPlayer change its fullscreen status, we must let the SVSAdManager know about it
        // so it can adjust the UI of the AdPlayer view.
        //////////////////////////////////////////////////////////////////////////////////////////////
        adManager?.contentPlayerIsFullscreen(true)
        // And update our constraints as well
        updatePlayerConstraints(fullscreenState: true)
    }
    
    
    func playerViewControllerDidRequest(toExitFullscreen videoPlayerViewController: PlayerViewController) {
        //////////////////////////////////////////////////////////////////////////////////////////////
        // When the AVPlayer change its fullscreen status, we must let the SVSAdManager know about it
        // so it can adjust the UI of the AdPlayer view.
        //////////////////////////////////////////////////////////////////////////////////////////////
        adManager?.contentPlayerIsFullscreen(false)
        // And update our constraints as well
        updatePlayerConstraints(fullscreenState: false)

    }
    
    func playerViewControllerDidRestart(videoPlayerViewController: PlayerViewController) {
        /////////////////////////////////////////////////////////////////////////////////////////////////
        // The user clicked on the restart button and the player will play its content from the beginning.
        // We should bypass the normal process here and called the replay method from the SVSAdManager
        // to display again all the ads.
        /////////////////////////////////////////////////////////////////////////////////////////////////
        adManager?.replay()
    }
    
    func playerViewControllerDidStop(videoPlayerViewController: PlayerViewController) {
        ////////////////////////////////////////////////////////////////////////////
        // The user clicked on the stop button. We have to notify the SVSAdManager.
        ////////////////////////////////////////////////////////////////////////////
        adManager?.stopAndTriggerPostrollIfAny(false)
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "player") {
            // Recover player view controller
            playerViewController = (segue.destination as! PlayerViewController)
            playerViewController.delegate = self
        }
    }
}

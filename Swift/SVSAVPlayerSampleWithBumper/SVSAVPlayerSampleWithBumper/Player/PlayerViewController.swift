//
//  PlayerViewController.swift
//  SVSAVPlayerSample
//
//  Created by Loïc GIRON DIT METAZ on 03/12/2021.
//

import UIKit
import AVFoundation

/////////////////////////////////////////////////////////////////////////////////////////////
// The PlayerViewController is the class where you will find only AVPlayer related content player sample.
/////////////////////////////////////////////////////////////////////////////////////////////

protocol PlayerViewControllerDelegate {
    
    func playerViewControllerDidRequest(toEnterFullscreen playerViewController: PlayerViewController)
    
    func playerViewControllerDidRequest(toExitFullscreen playerViewController: PlayerViewController)
    
    func playerViewControllerIsReadyToPlay(videoPlayerViewController: PlayerViewController)
    
    func playerViewControllerDidRestart(videoPlayerViewController: PlayerViewController)
    
    func playerViewControllerDidStop(videoPlayerViewController: PlayerViewController)
}

class PlayerViewController: UIViewController {
    
    // MARK: - Public properties
    
    var delegate: PlayerViewControllerDelegate?

    private let fullscreenButtonDisabled = false
    private let closeButtonDisabled = true

    
    private let controlsAutoHideDisabled = false
    private let controlsAutoHideDelay = TimeInterval(3.0)
    
    private static let contentVideoURL = URL(string: "https://ns.sascdn.com/video/movies/samples/intermediate_content.mp4")!
    
    private lazy var playerItem: AVPlayerItem = {
        return AVPlayerItem(asset: AVAsset(url: PlayerViewController.contentVideoURL))
    }()
    
    lazy var player: AVPlayer = {
        return AVPlayer(playerItem: self.playerItem)
    }()
    
    private var isPlaying: Bool {
        return player.rate > 0
    }
    
    private var isFullscreen: Bool = false
    
    private var playerPlaybackObserver: Any? = nil
    private var progressSliderIsBeingTouched = false
    private var isControlsDisplayed = true
    
    @IBOutlet weak var videoContainerView: VideoContainerView!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var enterExitFullscreenButton: UIButton!
    @IBOutlet weak var videoControlsButton: UIButton!
   
    @IBOutlet weak var closeButtonContainer: UIVisualEffectView!
    @IBOutlet weak var fullscreenButtonContainer: UIVisualEffectView!
    @IBOutlet weak var videoControlsContainer: UIVisualEffectView!
    
    @IBOutlet weak var adContainerView: UIView!
    @IBOutlet weak var beginBumperView: UIImageView!
    @IBOutlet weak var endBumperView: UIImageView!
    
    private var controlsAutoHideTimer: Timer? = nil
    

    
    deinit {
        unregisterPlayer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPlayer()
        displayControls(true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        displayControls(!videoControlsButton.isHidden)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        player.pause()
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func fullscreenButtonAction(_ sender: Any) {
        if isFullscreen {
            delegate?.playerViewControllerDidRequest(toExitFullscreen: self)
        } else {
            delegate?.playerViewControllerDidRequest(toEnterFullscreen: self)
        }
        isFullscreen = !isFullscreen
        updateEnterExitFullscreenButton()
    }
    
    @IBAction func progressSliderChanged(_ sender: Any) {
        let newTime = CMTime(seconds: Double(progressSlider.value / 1000), preferredTimescale: playerItem.duration.timescale)
        player.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    @IBAction func progressSliderTouchDown(_ sender: Any) {
        progressSliderIsBeingTouched = true
        stopControlsAutoHideTimer()
    }
    
    @IBAction func progressSliderTouchUpInside(_ sender: Any) {
        progressSliderIsBeingTouched = false
        startControlsAutoHideTimer()
    }
    
    @IBAction func progressSliderTouchUpOutside(_ sender: Any) {
        progressSliderIsBeingTouched = false
        startControlsAutoHideTimer()
    }
    
    @IBAction func controlsToggleButtonAction(_ sender: Any) {
        toggleControls()
    }
    
    func play() {
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func setFullscreen(_ fullscreen: Bool) {
        isFullscreen = fullscreen
        updateEnterExitFullscreenButton()
    }
    
    func showControls(_ show: Bool) {
        videoControlsButton.isHidden = !show
        displayControls(show)
    }
    
    private func startControlsAutoHideTimer() {
        if !controlsAutoHideDisabled {
            stopControlsAutoHideTimer()
            controlsAutoHideTimer = Timer.scheduledTimer(withTimeInterval: controlsAutoHideDelay, repeats: false) { _ in
                self.displayControls(false)
            }
        }
    }
    
    private func stopControlsAutoHideTimer() {
        if let controlsAutoHideTimer = controlsAutoHideTimer {
            controlsAutoHideTimer.invalidate()
        }
        controlsAutoHideTimer = nil
    }
    
    private func toggleControls() {
        displayControls(!isControlsDisplayed)
    }
    
    private func displayControls(_ display: Bool) {
        UIView.animate(withDuration: 0.25) { [self] in
            fullscreenButtonContainer.isHidden = fullscreenButtonDisabled ? true : !display
            closeButtonContainer.isHidden = closeButtonDisabled ? true : !display
            videoControlsContainer.isHidden = !display
        }
        
        if display == true {
            startControlsAutoHideTimer()
        }
        
        isControlsDisplayed = display
    }
    
    @IBAction func playPauseButtonAction(_ sender: Any) {
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        updateUIOnPlayback()
        startControlsAutoHideTimer()
    }
    
    @IBAction func restartButtonAction(_ sender: Any) {
        player.pause()
        player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
        startControlsAutoHideTimer()

        delegate?.playerViewControllerDidRestart(videoPlayerViewController: self)
    }
    
    @IBAction func stopButtonAction(_ sender: Any) {
        guard CMTIME_IS_VALID(playerItem.duration) && !CMTIME_IS_INDEFINITE(playerItem.duration) else { return }
        
        player.pause()
        player.seek(to: playerItem.duration, toleranceBefore: .zero, toleranceAfter: .positiveInfinity)
        startControlsAutoHideTimer()

        delegate?.playerViewControllerDidStop(videoPlayerViewController: self)
    }
    
    private func setupPlayer() {
        videoContainerView.player = player
        registerPlayer()
        updateEnterExitFullscreenButton()
    }
    
    private func registerPlayer() {
        playerItem.addObserver(self, forKeyPath: "status", options: [], context: nil)
        
        playerPlaybackObserver = player.addPeriodicTimeObserver(forInterval: CMTime(value: 250, timescale: 1000), queue: .main) { _ in
            self.updateUIOnPlayback()
        }
    }
    
    private func unregisterPlayer() {
        playerItem.removeObserver(self, forKeyPath: "status")
        
        if let playerPlaybackObserver = playerPlaybackObserver {
            player.removeTimeObserver(playerPlaybackObserver)
        }
        playerPlaybackObserver = nil
    }
    
    private func playerStatusDidChange() {
        updateUIOnPlayback()
        
        if player.status == .readyToPlay {
            progressSlider.minimumValue = 0.0
            progressSlider.maximumValue = Float(CMTimeGetSeconds(playerItem.duration) * 1000)
            
            self.delegate?.playerViewControllerIsReadyToPlay(videoPlayerViewController: self)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as? NSObject == playerItem && keyPath == "status" {
            playerStatusDidChange()
        }
    }
    
    private func updateUIOnPlayback() {
        guard !CMTIME_IS_INVALID(playerItem.currentTime()) && !CMTIME_IS_INDEFINITE(playerItem.currentTime()) else { return }
        
        if !progressSliderIsBeingTouched {
            // do not update the slider position when it is being touched to avoid a weird jumping effect
            progressSlider.value = Float(CMTimeGetSeconds(playerItem.currentTime()) * 1000.0)
        }
        updateTimerLabel()
        updatePlayPauseButton()
    }
    
    private func updateTimerLabel() {
        let currentTime = CMTimeGetSeconds(playerItem.currentTime())
        let totalTime = CMTimeGetSeconds(playerItem.duration)
        
        if let currentTimeString = stringFromTimeInterval(interval: currentTime), let totalTimeString = stringFromTimeInterval(interval: totalTime) {
            currentTimeLabel.text = currentTimeString
            totalTimeLabel.text = totalTimeString
        }
    }
    
    private func updatePlayPauseButton() {
        if isPlaying {
            playPauseButton.setImage(UIImage(systemName: "pause.fill")!.withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            playPauseButton.setImage(UIImage(systemName: "play.fill")!.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        playPauseButton.tintColor = .white
        playPauseButton.setTitle("", for: .normal)
    }
    
    private func updateEnterExitFullscreenButton() {
        if isFullscreen {
            enterExitFullscreenButton.setImage(UIImage(systemName: "arrow.down.right.and.arrow.up.left")!.withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            enterExitFullscreenButton.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right")!.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        enterExitFullscreenButton.tintColor = .white
        enterExitFullscreenButton.setTitle("", for: .normal)
    }
    
    private func stringFromTimeInterval(interval: TimeInterval) -> String? {
        guard !interval.isNaN && interval.isFinite else { return nil }
        
        let ti = Int(interval)
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = ti / 3600
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}

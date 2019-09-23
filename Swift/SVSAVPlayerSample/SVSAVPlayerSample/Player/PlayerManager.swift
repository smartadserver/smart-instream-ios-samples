//
//  PlayerManager.swift
//  SVSAVPlayerSample
//
//  Created by Loïc GIRON DIT METAZ on 28/08/2019.
//  Copyright © 2019 Smart AdServer. All rights reserved.
//

import UIKit
import AVFoundation

protocol PlayerManagerDelegate: AnyObject {
    func playerManager(playerManager: PlayerManager, didUpdateFullscreenStatus isFullscreen: Bool)
    func playerManagerIsReadyToPlay(playerManager: PlayerManager)
    func playerManagerDidReset(playerManager: PlayerManager)
    func playerManagerDidStop(playerManager: PlayerManager)
}

class PlayerManager : NSObject {
    
    private let controlBarHeight: CGFloat = 32.0
    private let controlMargin: CGFloat = 8.0
    
    weak var delegate: PlayerManagerDelegate?
    
    private let videoContainerView: VideoContainerView
    private let rootView: UIView
    
    private var controlsAreAutoHidden: Bool = false
    private var fullscreen: Bool = false
    
    lazy var playerItem: AVPlayerItem = { AVPlayerItem(url: URL(string: Constants.contentVideoURL)!) }()
    lazy var player: AVPlayer = { AVPlayer(playerItem: playerItem) }()
    private var playbackObserver: Any?
        
    // MARK: - Object lifecycle
    
    deinit {
        playerCleanUp()
        stopAutoHideTimer()
    }
    
    init(videoContainerView: VideoContainerView, rootView: UIView, delegate: PlayerManagerDelegate?) {
        self.videoContainerView = videoContainerView
        self.rootView = rootView
        self.delegate = delegate
        
        super.init()
        
        setupUI()
        playerSetUp()
    }
    
    // MARK: - Public API
    
    func play() {
        player.play()
        playPauseButton.isSelected = true
    }
    
    func pause() {
        player.pause()
        playPauseButton.isSelected = false
    }
    
    func updateFullscreenStatus(isFullscreen: Bool) {
        fullscreen = isFullscreen
        fullscreenButton.isSelected = isFullscreen
    }
    
    func showControl(_ show: Bool) {
        topControlBar.isHidden = !show
        bottomControlBar.isHidden = !show
    }
    
    func autoHideControls(hide: Bool) {
        controlsAreAutoHidden = hide
        
        UIView.animate(withDuration: 0.3) { [unowned self] in
            self.updateControlsFrames()
        }
        
        if !hide {
            self.startAutoHideTimer()
        }
    }
    
    func updateControlsFrames() {
        updateTopBarControlFrames()
        updateBottomBarControlFrames()
    }
    
    // MARK: - Player lifecycle
    
    private func playerSetUp() {
        videoContainerView.player = player
        registerKVO()
        
        playbackObserver = player.addPeriodicTimeObserver(forInterval: CMTime(value: 250, timescale: 1000), queue: nil) { [unowned self] (_) in
            self.updateSlider()
        }
    }
    
    private func playerCleanUp() {
        if let playbackObserver = playbackObserver {
            player.removeTimeObserver(playbackObserver)
            self.playbackObserver = nil
        }
        player.pause()
        unregisterKVO()
    }
    
    // MARK: - KVO
    
    private func registerKVO() {
        playerItem.addObserver(self, forKeyPath: "status", options: [], context: nil)
    }
    
    private func unregisterKVO() {
        playerItem.removeObserver(self, forKeyPath: "status")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (object as! NSObject) == playerItem && keyPath == "status" {
            playerItemStatusDidChange(status: playerItem.status)
        }
    }
    
    private func playerItemStatusDidChange(status: AVPlayerItem.Status) {
        if status == .readyToPlay {
            seekBar.minimumValue = 0
            seekBar.maximumValue = Float(CMTimeGetSeconds(playerItem.duration) * 1000)
            showControl(true)
            
            delegate?.playerManagerIsReadyToPlay(playerManager: self)
        }
    }
    
    // MARK: - UI
    
    private func setupUI() {
        let containerViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizerAction(sender:)))
        videoContainerView.addGestureRecognizer(containerViewTapGestureRecognizer)
        
        videoContainerView.addSubview(topControlBar)
        videoContainerView.addSubview(bottomControlBar)
        
        updateControlsFrames()
        startAutoHideTimer()
    }
    
    private func updateTopBarControlFrames() {
        topControlBar.frame = CGRect(x: 0, y: 0, width: videoContainerView.frame.size.width, height: controlHeight())
        resetButton.frame = CGRect(x: 0, y: 0, width: controlBarHeight, height: topControlBar.frame.size.height)
        stopButton.frame = CGRect(x: topControlBar.frame.size.width - controlBarHeight, y: 0, width: controlBarHeight, height: controlHeight())
        timeLabel.frame = CGRect(x: controlBarHeight, y: 0, width: topControlBar.frame.size.width - 2 * controlBarHeight, height: controlHeight())
    }
    
    private func updateBottomBarControlFrames() {
        // We have to calculate the videoViewHeight because the constraint are not always setted correctly.
        // For example, when going to landscape, constraints are updated AFTER we need the real size of the videoView.
        var calculatedVideoViewHeight: CGFloat = rootView.frame.size.width * 9 / 16
        
        // This is specific for the iPhone X (and probably iPhone after it). We use the safeArea to calculate the videoHeight.
        if #available(iOS 11.0, *) {
            let safeHeight: CGFloat = rootView.frame.size.height - rootView.safeAreaInsets.bottom
            if UIApplication.shared.statusBarOrientation.isLandscape && rootView.frame.size.height > safeHeight {
                calculatedVideoViewHeight = rootView.frame.size.height - rootView.safeAreaInsets.bottom
            }
        }
        
        let originY = controlsAreAutoHidden ? calculatedVideoViewHeight : calculatedVideoViewHeight - controlBarHeight
        bottomControlBar.frame = CGRect(x: 0, y: originY, width: videoContainerView.frame.size.width, height: controlHeight())
        playPauseButton.frame = CGRect(x: 0, y: 0, width: controlBarHeight, height: controlHeight())
        fullscreenButton.frame = CGRect(x: bottomControlBar.frame.size.width - controlBarHeight, y: 0, width: controlBarHeight, height: controlHeight())
        seekBar.frame = CGRect(x: controlBarHeight + controlMargin, y: 0, width: bottomControlBar.frame.size.width - 2 * controlBarHeight - 2 * controlMargin, height: controlHeight())
        seekBar.alpha = controlsAreAutoHidden ? 0 : 1
    }
    
    private func controlHeight() -> CGFloat {
        return controlsAreAutoHidden ? 0 : controlBarHeight
    }
    
    private func updateTimerLabel() {
        guard !CMTIME_IS_INVALID(playerItem.currentTime()) && !CMTIME_IS_INDEFINITE(playerItem.currentTime()) else { return }
        
        let currentTime = CMTimeGetSeconds(playerItem.currentTime())
        let totalTime = CMTimeGetSeconds(playerItem.duration)
        
        if let currentTimeString = stringFromTimeInterval(interval: currentTime), let totalTimeString = stringFromTimeInterval(interval: totalTime) {
            timeLabel.text = "\(currentTimeString) / \(totalTimeString)"
        }
    }
    
    private func updateSlider() {
        updateTimerLabel()
        seekBar.value = Float(CMTimeGetSeconds(playerItem.currentTime()) * 1000.0)
    }
    
    private func stringFromTimeInterval(interval: TimeInterval) -> String? {
        guard !interval.isNaN && interval.isFinite else { return nil }
        
        let ti = Int(interval)
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = ti / 3600
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    // MARK: - UI callbacks
    
    @objc func tapGestureRecognizerAction(sender: Any) {
        autoHideControls(hide: false)
    }
    
    @objc func resetButtonAction() {
        player.pause()
        player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
        
        delegate?.playerManagerDidReset(playerManager: self)
        startAutoHideTimer()
    }
    
    @objc func stopButtonAction() {
        guard CMTIME_IS_VALID(playerItem.duration) && !CMTIME_IS_INDEFINITE(playerItem.duration) else { return }
        
        player.pause()
        player.seek(to: playerItem.duration, toleranceBefore: .zero, toleranceAfter: .positiveInfinity)
        
        delegate?.playerManagerDidStop(playerManager: self)
        startAutoHideTimer()
    }
    
    @objc func playPauseButtonAction() {
        if playPauseButton.isSelected {
            pause()
        } else {
            play()
        }
        
        startAutoHideTimer()
    }
    
    @objc func fullscreenButtonAction() {
        fullscreen = !fullscreen
        fullscreenButton.isSelected = fullscreen
        
        delegate?.playerManager(playerManager: self, didUpdateFullscreenStatus: fullscreen)
        startAutoHideTimer()
    }
    
    @objc func seekBarValueChanged() {
        let newTime = CMTime(seconds: Double(seekBar.value / 1000), preferredTimescale: playerItem.duration.timescale)
        player.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
        
        startAutoHideTimer()
    }
    
    // MARK: - Auto hide control
    
    private var autoHideTimer: Timer?
    
    private func startAutoHideTimer() {
        stopAutoHideTimer()
        
        autoHideTimer = Timer.scheduledTimer(withTimeInterval: 4.5, repeats: false) { [weak self] (_) in
            self?.autoHideControls(hide: true)
        }
    }
    
    private func stopAutoHideTimer() {
        autoHideTimer?.invalidate()
        autoHideTimer = nil
    }
    
    // MARK: - Top control bar
    
    private lazy var topControlBar: UIView = { [unowned self] in
        let topControlBar = UIView(frame: .zero)
        topControlBar.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        topControlBar.addSubview(self.resetButton)
        topControlBar.addSubview(self.stopButton)
        topControlBar.addSubview(self.timeLabel)
        
        return topControlBar
    }()
    
    private lazy var resetButton: UIButton = { [unowned self] in
        let resetImage = UIImage(named: "reset")?.withRenderingMode(.alwaysTemplate)
        let resetButton = UIButton(type: .custom)
        resetButton.imageView?.tintColor = UIColor.white
        resetButton.setImage(resetImage, for: .normal)
        resetButton.addTarget(self, action: #selector(resetButtonAction), for: .touchUpInside)
        return resetButton
    }()
    
    private lazy var stopButton: UIButton = { [unowned self] in
        let stopImage = UIImage(named: "stop")?.withRenderingMode(.alwaysTemplate)
        let stopButton = UIButton(type: .custom)
        stopButton.imageView?.tintColor = UIColor.white
        stopButton.setImage(stopImage, for: .normal)
        stopButton.addTarget(self, action: #selector(stopButtonAction), for: .touchUpInside)
        return stopButton
    }()
    
    private lazy var timeLabel: UILabel = { [unowned self] in
        let timeLabel = UILabel(frame: .zero)
        timeLabel.textColor = UIColor.white
        timeLabel.font = UIFont.systemFont(ofSize: 14.0)
        timeLabel.textAlignment = .center
        return timeLabel
    }()

    // MARK: - Bottom control bar
    
    private lazy var bottomControlBar: UIView = { [unowned self] in
        let bottomControlBar = UIView(frame: .zero)
        bottomControlBar.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        bottomControlBar.addSubview(playPauseButton)
        bottomControlBar.addSubview(fullscreenButton)
        bottomControlBar.addSubview(seekBar)
        
        return bottomControlBar
    }()
    
    private lazy var playPauseButton: UIButton = { [unowned self] in
        let playImage = UIImage(named: "play")?.withRenderingMode(.alwaysTemplate)
        let pauseImage = UIImage(named: "pause")?.withRenderingMode(.alwaysTemplate)
        let playPauseButton = UIButton(type: .custom)
        playPauseButton.imageView?.tintColor = UIColor.white
        playPauseButton.setImage(playImage, for: .normal)
        playPauseButton.setImage(pauseImage, for: .selected)
        playPauseButton.addTarget(self, action: #selector(playPauseButtonAction), for: .touchUpInside)
        return playPauseButton
    }()
    
    private lazy var fullscreenButton: UIButton = { [unowned self] in
        let expandImage = UIImage(named: "expand")?.withRenderingMode(.alwaysTemplate)
        let shrinkImage = UIImage(named: "shrink")?.withRenderingMode(.alwaysTemplate)
        let fullscreenButton = UIButton(type: .custom)
        fullscreenButton.imageView?.tintColor = UIColor.white
        fullscreenButton.setImage(expandImage, for: .normal)
        fullscreenButton.setImage(shrinkImage, for: .selected)
        fullscreenButton.addTarget(self, action: #selector(fullscreenButtonAction), for: .touchUpInside)
        return fullscreenButton
    }()
    
    private lazy var seekBar: UISlider = { [unowned self] in
        let thumbImage = UIImage(named: "seekbar")?.withRenderingMode(.alwaysTemplate)
        let seekBar = UISlider(frame: .zero)
        seekBar.tintColor = UIColor.white
        seekBar.thumbTintColor = UIColor.white
        seekBar.setThumbImage(thumbImage, for: .normal)
        seekBar.addTarget(self, action: #selector(seekBarValueChanged), for: .valueChanged)
        return seekBar
    }()
    
}

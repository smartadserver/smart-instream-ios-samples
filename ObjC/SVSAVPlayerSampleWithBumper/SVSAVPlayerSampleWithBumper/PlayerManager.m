//
//  PlayerManager.m
//  SVSAVPlayerSample
//
//  Created by glaubier on 23/01/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#define kControlBarHeight       32.0
#define kControlMargin          8.0

#import "PlayerManager.h"
#import "Constants.h"

@interface PlayerManager ()

// External UI
@property (nonatomic, strong) VideoContainerView *videoContainerView;
@property (nonatomic, strong) UIView *rootView;

// AV Components
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) id playbackObserver;

// KVO
@property (nonatomic, assign) BOOL statusKVORegistered;

// Misc
@property (nonatomic, strong) NSTimer *autoHideTimer;
@property (nonatomic, assign) BOOL fullscreen;
@property (nonatomic, assign) BOOL controlsAreAutoHidden;

// UI
@property (nonatomic, strong) UITapGestureRecognizer *containerViewTapGesture;
@property (nonatomic, strong) UIView *topControlBar;
@property (nonatomic, strong) UIView *bottomControlBar;

// Top bar
@property (nonatomic, strong) UIButton *buttonReset;
@property (nonatomic, strong) UIButton *buttonStop;
@property (nonatomic, strong) UILabel *labelTime;

// Bottom bar
@property (nonatomic, strong) UISlider *seekBar;
@property (nonatomic, strong) UIButton *buttonPlayPause;
@property (nonatomic, strong) UIButton *buttonFullscreen;

@end

@implementation PlayerManager

#pragma mark - Object Lifecycle

- (void)dealloc {
    [self cleanup];
    
    if (self.autoHideTimer) {
        [self.autoHideTimer invalidate];
        self.autoHideTimer = nil;
    }
}


- (instancetype)initWithVideoContainerView:(VideoContainerView *)videoContainerView rootView:(UIView *)rootView delegate:(id<PlayerManagerDelegate>)delegate {
    self = [super init];

    if (self) {
        self.delegate = delegate;
        self.videoContainerView = videoContainerView;
        self.rootView = rootView;
        
        // Setup UI
        [self setupUI];
        
        // Create AV Player
        [self instantiatePlayer];
    }
    
    return self;
}

#pragma mark - Player Lifecycle

- (void)cleanup {
    if (self.player) {
        [self.player removeTimeObserver:self.playbackObserver];
        self.playbackObserver = nil;
        [self.player pause];
        [self unregisterStatusKVO];
    }
}


- (void)instantiatePlayer {
    if (self.player) {
        [self cleanup];
    }
    
    ////////////////////
    // Create AVPlayer.
    ////////////////////
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:ContentVideoURL]];
    self.player = [AVPlayer playerWithPlayerItem:item];
    
    [self.videoContainerView setPlayer:self.player];
    
    self.playerItem = item;
    [self registerStatusKVO];
    __block PlayerManager *weakSelf = self;
    self.playbackObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(250, 1000) queue:NULL usingBlock:^(CMTime time) {
        [weakSelf updateSlider];
    }];
}

#pragma mark - API Controls

- (void)play {
    [self.player play];
    self.buttonPlayPause.selected = YES;
}


- (void)pause {
    [self.player pause];
    self.buttonPlayPause.selected = NO;
}

#pragma mark - PlayerItem KVO

- (void)playerItemStatusDidChange:(AVPlayerItemStatus)status {
    if (status == AVPlayerStatusReadyToPlay) {
        self.seekBar.minimumValue = 0;
        self.seekBar.maximumValue = CMTimeGetSeconds(self.playerItem.duration) * 1000;
        [self showControls:YES];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(playerManagerIsReadyToPlay:)]) {
            [self.delegate playerManagerIsReadyToPlay:self];
        }
    }
}

#pragma mark - Player KVO

- (void)registerStatusKVO {
    if (!self.statusKVORegistered) {
        self.statusKVORegistered = YES;
        [self.playerItem addObserver:self forKeyPath:@"status" options:0 context:nil];
    }
}


- (void)unregisterStatusKVO {
    if (self.statusKVORegistered) {
        self.statusKVORegistered = NO;
        [self.playerItem removeObserver:self forKeyPath:@"status"];
    }
}


- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context {
    if (object == self.playerItem && [keyPath isEqualToString:@"status"]) {
        [self playerItemStatusDidChange:self.playerItem.status];
    }
}

#pragma mark - UI

- (void)setupUI {
    // View Container view
    self.containerViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    [self.videoContainerView addGestureRecognizer:self.containerViewTapGesture];
    
    // UI Top Bar
    [self setupTopControlBar];
    
    // UI Bottom Bar
    [self setupBottomControlBar];
    
    // Update frames
    [self updateControlsFrames];
    
    // Auto hide
    [self startAutoHideTimer];
}


- (void)setupTopControlBar {
    self.topControlBar = [[UIView alloc] initWithFrame:CGRectZero];
    self.topControlBar.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.videoContainerView addSubview:self.topControlBar];
    
    // Btn reset
    UIImage *imgReset = [[UIImage imageNamed:@"reset"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.buttonReset = [UIButton buttonWithType:UIButtonTypeCustom];
    self.buttonReset.imageView.tintColor = [UIColor whiteColor];
    [self.buttonReset setImage:imgReset forState:UIControlStateNormal];
    [self.buttonReset addTarget:self action:@selector(resetTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.topControlBar addSubview:self.buttonReset];
    
    // Btn stop
    UIImage *imgStop = [[UIImage imageNamed:@"stop"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.buttonStop = [UIButton buttonWithType:UIButtonTypeCustom];
    self.buttonStop.imageView.tintColor = [UIColor whiteColor];
    [self.buttonStop setImage:imgStop forState:UIControlStateNormal];
    [self.buttonStop addTarget:self action:@selector(stopTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.topControlBar addSubview:self.buttonStop];
    
    // Label
    self.labelTime = [[UILabel alloc] initWithFrame:CGRectZero];
    self.labelTime.textColor = [UIColor whiteColor];
    self.labelTime.font = [UIFont systemFontOfSize:14.0];
    self.labelTime.textAlignment = NSTextAlignmentCenter;
    [self.topControlBar addSubview:self.labelTime];
}


- (void)setupBottomControlBar {
    self.bottomControlBar = [[UIView alloc] initWithFrame:CGRectZero];
    self.bottomControlBar.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.videoContainerView addSubview:self.bottomControlBar];
    
    // Btn play
    UIImage *imgPlay = [[UIImage imageNamed:@"play"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *imgPause = [[UIImage imageNamed:@"pause"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.buttonPlayPause = [UIButton buttonWithType:UIButtonTypeCustom];
    self.buttonPlayPause.imageView.tintColor = [UIColor whiteColor];
    [self.buttonPlayPause setImage:imgPlay forState:UIControlStateNormal];
    [self.buttonPlayPause setImage:imgPause forState:UIControlStateSelected];
    [self.buttonPlayPause addTarget:self action:@selector(playPauseTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomControlBar addSubview:self.buttonPlayPause];   
    
    // Btn fullscreen
    UIImage *imgExpand = [[UIImage imageNamed:@"expand"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *imgShrink = [[UIImage imageNamed:@"shrink"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.buttonFullscreen = [UIButton buttonWithType:UIButtonTypeCustom];
    self.buttonFullscreen.imageView.tintColor = [UIColor whiteColor];
    [self.buttonFullscreen setImage:imgExpand forState:UIControlStateNormal];
    [self.buttonFullscreen setImage:imgShrink forState:UIControlStateSelected];
    [self.buttonFullscreen addTarget:self action:@selector(fullscreenTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomControlBar addSubview:self.buttonFullscreen];
    
    // Seek Bar
    UIImage *thumbImage = [[UIImage imageNamed:@"seekbar"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.seekBar = [[UISlider alloc] initWithFrame:CGRectZero];
    self.seekBar.tintColor = [UIColor whiteColor];
    [self.seekBar setThumbTintColor:[UIColor whiteColor]];
    [self.seekBar setThumbImage:thumbImage forState:UIControlStateNormal];
    [self.seekBar addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.bottomControlBar addSubview:self.seekBar];
}


- (void)updateControlsFrames {
    [self updateTopBarControlFrames];
    [self updateBottomBarControlFrames];
}


- (void)updateTopBarControlFrames {
    self.topControlBar.frame = CGRectMake(0, 0, self.videoContainerView.frame.size.width,  [self controlHeight]);
    self.buttonReset.frame = CGRectMake(0, 0, kControlBarHeight, self.topControlBar.frame.size.height);
    self.buttonStop.frame = CGRectMake(self.topControlBar.frame.size.width - kControlBarHeight, 0, kControlBarHeight, [self controlHeight]);
    self.labelTime.frame = CGRectMake(kControlBarHeight, 0, self.topControlBar.frame.size.width - 2 * kControlBarHeight, [self controlHeight]);
}


- (void)updateBottomBarControlFrames {
    // We have to calculate the videoViewHeight because the constraint are not always setted correctly.
    // For example, when going to landscape, constraints are updated AFTER we need the real size of the videoView.
    CGFloat calculatedVideoViewHeight = self.rootView.frame.size.width * 9 / 16;
    
    // This is specific for the iPhone X (and probably iPhone after it). We use the safeArea to calculate the videoHeight.
    if (@available(iOS 11.0, *)) {
        CGFloat safeHeight = self.rootView.frame.size.height - self.rootView.safeAreaInsets.bottom;
        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) && self.rootView.frame.size.height > safeHeight) {
            calculatedVideoViewHeight = self.rootView.frame.size.height - self.rootView.safeAreaInsets.bottom;
        }
    }
    
    CGFloat originY = self.controlsAreAutoHidden ? calculatedVideoViewHeight : calculatedVideoViewHeight - kControlBarHeight;
    self.bottomControlBar.frame = CGRectMake(0, originY, self.videoContainerView.frame.size.width, [self controlHeight]);
    self.buttonPlayPause.frame = CGRectMake(0, 0, kControlBarHeight, [self controlHeight]);
    self.buttonFullscreen.frame = CGRectMake(self.bottomControlBar.frame.size.width - kControlBarHeight, 0, kControlBarHeight, [self controlHeight]);
    self.seekBar.frame = CGRectMake(kControlBarHeight + kControlMargin, 0, self.bottomControlBar.frame.size.width - 2 * kControlBarHeight - 2 * kControlMargin, [self controlHeight]);
    self.seekBar.alpha = !self.controlsAreAutoHidden;
}


- (CGFloat)controlHeight {
    return self.controlsAreAutoHidden ? 0 : kControlBarHeight;
}


- (void)showControls:(BOOL)show {
    self.topControlBar.hidden = !show;
    self.bottomControlBar.hidden = !show;
}

#pragma mark - Video Control

- (void)updateTimerLabel {
    NSTimeInterval currentTime = CMTimeGetSeconds(self.player.currentItem.currentTime);
    NSTimeInterval totalTime = CMTimeGetSeconds(self.player.currentItem.duration);
    self.labelTime.text = [NSString stringWithFormat:@"%@ / %@", [self stringFromTimeInterval:currentTime], [self stringFromTimeInterval:totalTime]];
}


- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
}


- (void)updateSlider {
    [self updateTimerLabel];
    self.seekBar.value =  CMTimeGetSeconds(self.playerItem.currentTime) * 1000;
}


- (void)sliderValueChanged:(id)sender {
    CMTime newTime = CMTimeMakeWithSeconds(self.seekBar.value / 1000, self.player.currentItem.duration.timescale);
    [self.player seekToTime:newTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self startAutoHideTimer];
}


- (void)resetTapped:(id)sender {
    [self.player pause];
    [self.player seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerManagerDidReset:)]) {
        [self.delegate playerManagerDidReset:self];
    }
    
    [self startAutoHideTimer];
}


- (void)playPauseTapped:(id)sender {
    if ([self.buttonPlayPause isSelected]) {
        [self pause];
    } else {
        [self play];
    }
    [self startAutoHideTimer];
}


- (void)fullscreenTapped:(id)sender {
    self.fullscreen = !self.fullscreen;
    self.buttonFullscreen.selected = self.fullscreen;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerManager:didUpdateFullscreenStatus:)]) {
        [self.delegate playerManager:self didUpdateFullscreenStatus:self.fullscreen];
    }
    
    [self startAutoHideTimer];
}


- (void)stopTapped:(id)sender {
    [self.player pause];
    [self.player seekToTime:self.player.currentItem.duration toleranceBefore:kCMTimeZero toleranceAfter:kCMTimePositiveInfinity];
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerManagerDidStop:)]) {
        [self.delegate playerManagerDidStop:self];
    }
    [self startAutoHideTimer];
}


- (void)tapGestureAction:(id)sender {
    [self autoHideControls:NO];
}

#pragma mark - AutoHide Controls

- (void)startAutoHideTimer {
    if (self.autoHideTimer) {
        [self.autoHideTimer invalidate];
        self.autoHideTimer = nil;
    }
    self.autoHideTimer = [NSTimer scheduledTimerWithTimeInterval:4.5 target:self selector:@selector(hideTimerHit) userInfo:nil repeats:NO];
}


- (void)hideTimerHit {
    [self autoHideControls:YES];
}


- (void)autoHideControls:(BOOL)hide {
    self.controlsAreAutoHidden = hide;
    
    [UIView animateWithDuration:0.3 animations:^{
        [self updateControlsFrames];
    }];
    
    if (!hide) {
        [self startAutoHideTimer];
    }
}

#pragma mark - Fullscreen

// called when the fullscreen update is due to orientation, only for updating UI.
- (void)updateFullscreenStatus:(BOOL)isFullscreen {
    self.fullscreen = isFullscreen;
    self.buttonFullscreen.selected = isFullscreen;
}

@end

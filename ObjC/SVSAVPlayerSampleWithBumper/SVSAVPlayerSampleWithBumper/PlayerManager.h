//
//  PlayerManager.h
//  SVSAVPlayerSample
//
//  Created by glaubier on 23/01/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "VideoContainerView.h"

@class PlayerManager;

@protocol PlayerManagerDelegate <NSObject>

- (void)playerManager:(PlayerManager *)manager didUpdateFullscreenStatus:(BOOL)isFullscreen;

- (void)playerManagerIsReadyToPlay:(PlayerManager *)manager;
- (void)playerManagerDidReset:(PlayerManager *)manager;
- (void)playerManagerDidStop:(PlayerManager *)manager;

@end

@interface PlayerManager : NSObject

@property (nonatomic, weak) id<PlayerManagerDelegate> delegate;
@property (nonatomic, strong) AVPlayer *player;

#pragma mark - Init
- (instancetype)initWithVideoContainerView:(VideoContainerView *)videoContainerView rootView:(UIView *)rootView  delegate:(id <PlayerManagerDelegate>)delegate;

#pragma mark - Playback Control
- (void)play;
- (void)pause;

#pragma mark - Frames
- (void)updateControlsFrames;

#pragma mark - UI
- (void)showControls:(BOOL)show;
- (void)autoHideControls:(BOOL)hide;
- (void)updateFullscreenStatus:(BOOL)isFullscreen;

@end

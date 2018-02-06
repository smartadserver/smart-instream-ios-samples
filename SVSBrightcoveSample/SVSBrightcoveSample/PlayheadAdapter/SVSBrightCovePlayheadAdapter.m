//
//  SVSBrightCovePlayheadAdapter.h
//  BrightCoveSample
//
//  Created by Thomas Geley on 04/10/2017.
//  Copyright © 2017 Smart Adserver. All rights reserved.
//

#import "SVSBrightCovePlayheadAdapter.h"
#import <BrightcovePlayerSDK/BrightcovePlayerSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface SVSBrightCovePlayheadAdapter ()
@property (nonatomic, weak) id <BCOVPlaybackSession> playbackSession;
@property (nonatomic, weak) AVPlayer *player;
@property (nonatomic, assign) BOOL infiniteDuration;
@end

@implementation SVSBrightCovePlayheadAdapter

- (instancetype)initWithBrightCovePlaybackSession:(id <BCOVPlaybackSession>)session unknownContentDuration:(BOOL)unknownContentDuration; {
    
    self = [super init];
    
    if (self) {
        self.playbackSession = session;
        self.player = session.player;
        self.infiniteDuration = unknownContentDuration;
    }
    
    return self;
}


#pragma mark - Playhead Protocol

- (NSTimeInterval)contentPlayerCurrentTime {
    NSTimeInterval interval = 0;
    interval += CMTimeGetSeconds(self.player.currentItem.currentTime);
    return interval;
}


- (NSTimeInterval)contentPlayerTotalTime {
    if (self.infiniteDuration) {
        return kSVSContentPlayerTotalDurationInfinite;
    }
    
    NSTimeInterval interval = 0;
    interval += CMTimeGetSeconds(self.player.currentItem.duration);
    return interval;
}


- (float)contentPlayerVolumeLevel {
    return self.player.volume;
}


- (BOOL)contentPlayerIsPlaying {
    return self.player.rate != 0;
}

@end

NS_ASSUME_NONNULL_END

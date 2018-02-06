//
//  SVSJWPlayerPlayheadAdapter.m
//  JWSample
//
//  Created by Thomas Geley on 03/10/2017.
//  Copyright © 2017 Smart Adserver. All rights reserved.
//

#import "SVSJWPlayerPlayheadAdapter.h"
#import <JWPlayer_iOS_SDK/JWPlayerController.h>

NS_ASSUME_NONNULL_BEGIN

@interface SVSJWPlayerPlayheadAdapter ()
@property (nonatomic, weak) JWPlayerController *player;
@property (nonatomic, assign) BOOL infiniteDuration;
@end

@implementation SVSJWPlayerPlayheadAdapter

- (instancetype)initWithJWPlayerController:(JWPlayerController *)playerController unknownContentDuration:(BOOL)unknownContentDuration; {
    self = [super init];
    
    if (self) {
        self.player = playerController;
        self.infiniteDuration = unknownContentDuration;
    }
    
    return self;
}

- (NSTimeInterval)contentPlayerCurrentTime {
    return [self.player.playbackPosition doubleValue];
}


- (NSTimeInterval)contentPlayerTotalTime {
    if (self.infiniteDuration) {
        return kSVSContentPlayerTotalDurationInfinite;
    }
    
    return self.player.duration;
}


- (float)contentPlayerVolumeLevel {
    return self.player.volume;
}


- (BOOL)contentPlayerIsPlaying {
    return [self.player.playerState isEqualToString:@"playing"];
}

@end

NS_ASSUME_NONNULL_END

//
//  VideoContainerView.m
//  SVSAVPlayerSample
//
//  Created by glaubier on 17/01/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import "VideoContainerView.h"

@implementation VideoContainerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayer *)player {
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

@end


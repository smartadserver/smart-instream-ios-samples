//
//  SVSAVPlayerPlayHeadAdapter.h
//  SVSVideoKit
//
//  Created by Thomas Geley on 19/05/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SVSContentPlayerPlayHead;
@class AVPlayer;

/**
 This class is a convenience adapter that implements the SVSContentPlayerPlayHead protocol for AVPlayer instances.
 Use it if your content player is an instance of AVPlayer.
 */
@interface SVSAVPlayerPlayHeadAdapter : NSObject <SVSContentPlayerPlayHead>

#pragma mark - Playhead initialization

/**
 Initialize an instance of SVSAVPlayerPlayHeadAdapter.
 
 @param player the AVPlayer instance used to play your content.
 @param unknownContentDuration Indicates whether or not the content is a live a feed, meaning its duration is unknown / infinite.
 
 @return An initialized instance of SVSAVPlayerPlayHeadAdapter.
*/
- (instancetype)initWithAVPlayer:(AVPlayer *)player unknownContentDuration:(BOOL)unknownContentDuration;

@end

NS_ASSUME_NONNULL_END

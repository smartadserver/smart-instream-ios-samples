//
//  SVSContentPlayerPlayHead.h
//  SVSVideoKit
//
//  Created by Thomas Geley on 27/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kSVSContentPlayerTotalDurationInfinite                          -1
#define kSVSContentPlayerTotalDurationStillUnknown                      0

NS_ASSUME_NONNULL_BEGIN

/**
 Protocol used to describe the state of a content player.
 
 Implement this protocol to allow your SVSAdManager instance to know the current state of the content
 player. The Playhead will allow the SVSAdManager to load and start ads at the right time and to configure the
 ad player depending on the configuration of the content player.
 
 @warning Every methods of this protocol are required and must be implemented to play ads!
 */
@protocol SVSContentPlayerPlayHead <NSObject>

@required

/**
 Returns the current time of the content player.
 
 @return The current time of the content player.
 */
- (NSTimeInterval)contentPlayerCurrentTime;

/**
 Returns the total time of the media loaded in the content player.

 This time can be equal to the constant kSVSContentPlayerTotalDurationStillUnknown if it is
 not known yet (ie: the content is still loading), or equal to kSVSContentPlayerTotalDurationInfinite when the content player
 is displaying a stream.
 
 @return The total time of the media loaded in the content player.
 */
- (NSTimeInterval)contentPlayerTotalTime;

/**
 Returns the volume of the content player (floating point number between 0.0 and 1.0).

 This value will be used to set the volume of the Ad Player when starting an Ad Break.
 
 @return The volume of the content player.
 */
- (float)contentPlayerVolumeLevel;

/**
 Returns whether or not the content player is playing. Should return NO when the content player is paused or stopped
 
 @return Whether or not the content player is playing.
 */
- (BOOL)contentPlayerIsPlaying;

@end

NS_ASSUME_NONNULL_END

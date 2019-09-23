//
//  SVSBrightCovePlayheadAdapter.h
//  BrightCoveSample
//
//  Created by Thomas Geley on 04/10/2017.
//  Copyright © 2017 Smart Adserver. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SVSVideoKit/SVSVideoKit.h>

@protocol BCOVPlaybackSession;

NS_ASSUME_NONNULL_BEGIN

/**
 This class is a convenience adapter that implements the SVSContentPlayerPlayHead protocol for BCOVPlaybackSession instances.
 Use it if your content player is BrightCove.
 */
@interface SVSBrightCovePlayheadAdapter : NSObject <SVSContentPlayerPlayHead>

/**
 Initialize an instance of SVSBrightCovePlayheadAdapter.
 
 @param session The BCOVPlaybackSession instance used to play your content.
 @param unknownContentDuration Indicates whether or not the content is a live a feed, meaning its duration is unknown / infinite.
 
 @return An initialized instance of SVSBrightCovePlayheadAdapter.
 */
- (instancetype)initWithBrightCovePlaybackSession:(id <BCOVPlaybackSession>)session unknownContentDuration:(BOOL)unknownContentDuration;
@end

NS_ASSUME_NONNULL_END

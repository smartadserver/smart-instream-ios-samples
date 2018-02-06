//
//  SVSJWPlayerPlayheadAdapter.h
//  JWSample
//
//  Created by Thomas Geley on 03/10/2017.
//  Copyright © 2017 Smart Adserver. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SVSVideoKit/SVSVideoKit.h>

@class JWPlayerController;

NS_ASSUME_NONNULL_BEGIN

/**
 This class is a convenience adapter that implements the SVSContentPlayerPlayHead protocol for JWPlayerController instances.
 Use it if your content player is an instance of JWPlayerController.
 */

@interface SVSJWPlayerPlayheadAdapter : NSObject <SVSContentPlayerPlayHead>

/**
 Initialize an instance of SVSJWPlayerPlayheadAdapter.
 
 @param playerController the JWPlayerController instance used to play your content.
 @param unknownContentDuration Indicates whether or not the content is a live a feed, meaning its duration is unknown / infinite.
 
 @return An initialized instance of SVSJWPlayerPlayheadAdapter.
 */
- (instancetype)initWithJWPlayerController:(JWPlayerController *)playerController unknownContentDuration:(BOOL)unknownContentDuration;

@end

NS_ASSUME_NONNULL_END

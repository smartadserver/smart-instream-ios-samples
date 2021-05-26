//
//  SVSCuePoint.h
//  SVSVideoKit
//
//  Created by Thomas Geley on 16/05/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Point in the content video when a midroll ad break will occur.
 */
@interface SVSCuePoint : NSObject

/// The content's player time where this CuePoint will trigger a MidRoll AdBreak.
@property (nonatomic, readonly) NSTimeInterval adBreakTime;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

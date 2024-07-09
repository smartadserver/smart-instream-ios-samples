//
//  SVSAdInfo.h
//  SVSVideoKit
//
//  Created by Guillaume LAUBIER on 03/06/2024.
//  Copyright © 2024 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SVSAdProgrammaticInfo;

/// Model class centralizing useful information for publishers.
@interface SVSAdInfo : NSObject

/// The insertion ID corresponding to this ad if available, nil otherwise.
@property (readonly, nullable) NSString *insertionID;

/// The Universal Ad ID corresponding to this ad if available, nil otherwise.
@property (readonly, nullable) NSString *universalAdID;

/// All programmatic info corresponding to this ad if available, nil otherwise.
@property (readonly, nullable) SVSAdProgrammaticInfo *programmaticInfo;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

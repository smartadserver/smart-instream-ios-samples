//
//  SVSAdPlayerConfigurationDisplay.h
//  SVSVideoKit
//
//  Created by Loïc GIRON DIT METAZ on 18/04/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Represents the ad player display configuration.
 */
@interface SVSAdPlayerConfigurationDisplayOptions : NSObject <NSCopying>

#pragma mark - Initialization

/**
 Initialize a new instance of SVSAdPlayerConfigurationDisplay with the default configuration.
 
 @return The initialized SVSAdPlayerConfigurationDisplay instance.
 */
- (instancetype)init;

#pragma mark - Configuration properties

/**
 YES to show the ad player fullscreen button, NO to hide it.

 @note If your content player is already fullscreen, you should set it to NO.

 Default: YES.
 */
@property (nonatomic, assign) BOOL enableFullscreen;

/**
 YES to display a countdown until the end of the Ad break.
 
 Default: YES.
 */
@property (nonatomic, assign) BOOL enableCountdownVideo;

/**
 YES to display a countdown before the Ad can be skipped.
 
 @note This has no effect if the Ad is not skippable.
 
 Default: YES.
*/
@property (nonatomic, assign) BOOL enableCountdownSkip;

@end

NS_ASSUME_NONNULL_END

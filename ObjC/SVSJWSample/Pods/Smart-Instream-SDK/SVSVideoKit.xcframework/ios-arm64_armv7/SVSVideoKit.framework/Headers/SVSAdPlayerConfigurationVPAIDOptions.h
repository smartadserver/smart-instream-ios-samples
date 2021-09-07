//
//  SVSAdPlayerConfigurationVPAIDOptions.h
//  SVSVideoKit
//
//  Created by Loïc GIRON DIT METAZ on 18/04/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Hold the configuration options related to VPAID.
 */
@interface SVSAdPlayerConfigurationVPAIDOptions : NSObject <NSCopying, NSCoding>

#pragma mark - Initialization

/**
 Initialize a new instance of SVSAdPlayerConfigurationVPAIDOptions with the default configuration.
 
 @return The initialized SVSAdPlayerConfigurationVPAIDOptions instance.
 */
- (instancetype)init;

#pragma mark - Configuration properties

/**
 YES to show the countdown before the end of the linear break, NO to hide.
 
 @note This might interfere with the creative's controls and degrade the user experience.

 Default: NO
*/
@property (nonatomic, assign) BOOL enableCountdownVideo;

/**
 YES to show a skip button over VPAID ads, NO to hide.

 @note This might interfere with the creative's controls and degrade the user experience.

 Default: NO
 
*/
@property (nonatomic, assign) BOOL enableSkip;

@end

NS_ASSUME_NONNULL_END

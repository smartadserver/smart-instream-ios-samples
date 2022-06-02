//
//  SCSPostClickManager.h
//  SCSCoreKit
//
//  Created by Thomas Geley on 06/09/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCSPostClickManagerProtocol.h"
#import "SCSPostClickManagerDelegate.h"
#import "SCSPixelManager.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Config class that can be used to customize the behavior of the post click manager.
 */
@interface SCSPostClickManagerConfig : NSObject

/// YES if the post click manager should force the URL opening outside of the app, NO otherwise (default).
@property (assign) BOOL forceRedirectToThirdParty;

@end

/**
 Default SCSPostClickManagerProtocol implementation.
 */
@interface SCSPostClickManager : NSObject <SCSPostClickManager>

- (instancetype)init NS_UNAVAILABLE;

/**
 Public Initializer
 
 @param delegate the Delegate for the SCSPostClickManager instance.
 
 @return an initialized SCSPostClickManager instance.
 */
- (instancetype)initWithDelegate:(id <SCSPostClickManagerDelegate>)delegate;

/**
 Public Initializer
 
 @param pixelManager The pixel manager that is going to be used to fire click tracking pixels.
 @param delegate the Delegate for the SCSPostClickManager instance.
 
 @return an initialized SCSPostClickManager instance.
 */
- (instancetype)initWithPixelManager:(SCSPixelManager *)pixelManager delegate:(id <SCSPostClickManagerDelegate>)delegate NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END

//
//  SVSEnums.h
//  SVSVideoKit
//
//  Created by Thomas Geley on 10/04/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

/// The type of ad break.
typedef NS_ENUM(NSInteger, SVSAdBreakType) {
    /// Type of the ad break unknown.
    SVSAdBreakTypeUnknown = -INT_MAX,
    
    /// Overlay ad break (unused for now).
    SVSAdBreakTypeOverlay = 0,
    
    /// Preroll ad break.
    SVSAdBreakTypePreroll = 1,
    
    /// Midroll ad break.
    SVSAdBreakTypeMidroll = 2,
    
    /// Postroll ad break.
    SVSAdBreakTypePostroll = 3,
};


/// The channel type of the current ad.
typedef NS_ENUM(NSInteger, SVSRemoteLogChannelType) {
    /// The channel type is unknown.
    SVSRemoteLogChannelTypeUnknown = -1,
    
    /// There is no current ad because of a 'no ad'.
    SVSRemoteLogChannelTypeNoAd = 0,
    
    /// The current ad is a direct ad.
    SVSRemoteLogChannelTypeDirect = 1,
    
    /// The current ad is a RTB ad.
    SVSRemoteLogChannelTypeRTB = 2,
};

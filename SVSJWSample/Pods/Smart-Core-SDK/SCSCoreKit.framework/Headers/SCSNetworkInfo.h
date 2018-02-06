//
//  SCSNetworkInfo.h
//  SCSCoreKit
//
//  Created by Loïc GIRON DIT METAZ on 22/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Type of connection that is being used by the device (if applicable).
typedef NS_ENUM(NSUInteger, SCSNetworkInfoConnectionType) {
    /// No connection is used (or connection type unknown).
    SCSNetworkInfoConnectionTypeNotReachableOrUnknown,
    
    /// A WiFi connection is being used.
    SCSNetworkInfoConnectionTypeWiFi,
    
    /// A non WiFi connection is being used (probably a data connection).
    SCSNetworkInfoConnectionTypeOther,
};

/// Current status of the network connection.
typedef NS_ENUM(NSUInteger, SCSNetworkInfoNetworkStatus) {
    /// Network status unknown.
    SCSNetworkInfoNetworkStatusUnknown,
    
    /// The network is reachable.
    SCSNetworkInfoNetworkStatusNotReachable,
    
    /// The network is not reachable.
    SCSNetworkInfoNetworkStatusReachable,
};


/// Current radio technology used by the device
typedef NS_ENUM(NSUInteger, SCSNetworkInfoNetworkAccessType) {
    /// Radio Technology is unknown.
    SCSNetworkInfoNetworkAccessTypeUnknown,
    
    /// Radio Technology is Edge or equivalent.
    SCSNetworkInfoNetworkAccessTypeEdge,
    
    /// Radio Technology is 3G or equivalent.
    SCSNetworkInfoNetworkAccessType3G,
    
    /// Radio Technology is 3G+ or equivalent.
    SCSNetworkInfoNetworkAccessType3GPlus,
    
    /// Radio Technology is H+ or equivalent.
    SCSNetworkInfoNetworkAccessTypeHPlus,
    
    /// Radio Technology is 4G or equivalent.
    SCSNetworkInfoNetworkAccessType4G,
    
    /// Radio Technology is WIFI or equivalent.
    SCSNetworkInfoNetworkAccessTypeWIFI,
};

/**
 Class used to retrieve network informations.
 */
@interface SCSNetworkInfo : NSObject

/// The shared instance of the SCSNetworkInfo object.
@property (class, nonatomic, readonly) SCSNetworkInfo *sharedInstance NS_SWIFT_NAME(shared);

/// The current network status of the data connection.
@property (nonatomic, readonly) SCSNetworkInfoNetworkStatus networkStatus;

/// The type (wifi / data) of data connection currently in use.
@property (nonatomic, readonly) SCSNetworkInfoConnectionType networkType;

/// The type network access technology type.
@property (nonatomic, readonly) SCSNetworkInfoNetworkAccessType networkAccessType;

/// true if the network is reachable, false otherwise.
@property (nonatomic, readonly) BOOL isNetworkReachable;

/// true if the network is reachable using a wifi connection (or equivalent), false otherwise.
@property (nonatomic, readonly) BOOL isReachableOnWiFi;

/// The local IP address of the Wi-Fi network interface (aka 'en0') if available.
///
/// Note: this property will be nil if the Wi-Fi is disabled and will return the LOCAL IP ADDRESS
/// if the Wi-Fi is enabled, not the WAN address!
@property (nonatomic, readonly) NSString *wifiLocalIPAddress;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

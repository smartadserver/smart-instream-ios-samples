//
//  SCSCoreKitTV.h
//  SCSCoreKitTV
//
//  Created by Thomas Geley on 28/01/2018.
//  Copyright © 2018 Smart AdServer. All rights reserved.
//

#import <UIKit/UIKit.h>

// Components
#import <SCSCoreKitTV/SCSVASTErrors.h>
#import <SCSCoreKitTV/SCSVASTError.h>
#import <SCSCoreKitTV/SCSVASTURL.h>
#import <SCSCoreKitTV/SCSVASTTrackingEvent.h>
#import <SCSCoreKitTV/SCSVASTViewabilityEvent.h>
#import <SCSCoreKitTV/SCSVASTClickEvent.h>

#import <SCSCoreKitTV/SCSVASTModel.h>
#import <SCSCoreKitTV/SCSVASTAd.h>
#import <SCSCoreKitTV/SCSVASTAdInline.h>
#import <SCSCoreKitTV/SCSVASTAdWrapper.h>
#import <SCSCoreKitTV/SCSVASTCreative.h>
#import <SCSCoreKitTV/SCSVASTCreativeLinear.h>
#import <SCSCoreKitTV/SCSVASTCreativeNonLinear.h>
#import <SCSCoreKitTV/SCSVASTCreativeCompanion.h>
#import <SCSCoreKitTV/SCSVASTCreativeIcon.h>
#import <SCSCoreKitTV/SCSVASTMediaFile.h>
#import <SCSCoreKitTV/SCSVASTAdExtension.h>
#import <SCSCoreKitTV/SCSVASTAdVerification.h>
#import <SCSCoreKitTV/SCSVASTAdVerificationResource.h>
#import <SCSCoreKitTV/SCSVASTAdVerificationEvent.h>
#import <SCSCoreKitTV/SCSVASTUniversalAdId.h>

#import <SCSCoreKitTV/SCSVASTMediaFileSelector.h>
#import <SCSCoreKitTV/SCSVASTPixelManager.h>

#import <SCSCoreKitTV/SCSVASTParser.h>
#import <SCSCoreKitTV/SCSVASTParserResponse.h>
#import <SCSCoreKitTV/SCSVASTModelGenerator.h>

#import <SCSCoreKitTV/SCSVideoAdProtocol.h>
#import <SCSCoreKitTV/SCSVASTAdAdapterProtocol.h>
#import <SCSCoreKitTV/SCSVASTManagerProtocol.h>
#import <SCSCoreKitTV/SCSVASTManagerDelegate.h>
#import <SCSCoreKitTV/SCSVASTManagerConfig.h>
#import <SCSCoreKitTV/SCSVASTManager.h>
#import <SCSCoreKitTV/SCSVASTManagerResponse.h>
#import <SCSCoreKitTV/SCSVASTTrackingEventFactory.h>
#import <SCSCoreKitTV/SCSVASTAdExtensionAdVerification.h>

#import <SCSCoreKitTV/SCSTrackingEvent.h>
#import <SCSCoreKitTV/SCSTrackingEventFactory.h>
#import <SCSCoreKitTV/SCSTrackingEventDefaultFactory.h>
#import <SCSCoreKitTV/SCSTrackingEventManagerProtocol.h>
#import <SCSCoreKitTV/SCSTrackingEventManager.h>
#import <SCSCoreKitTV/SCSTrackingEventManagerDelegate.h>
#import <SCSCoreKitTV/SCSVideoTrackingEvent.h>
#import <SCSCoreKitTV/SCSVideoTrackingEventManagerProtocol.h>
#import <SCSCoreKitTV/SCSVideoTrackingEventManager.h>
#import <SCSCoreKitTV/SCSViewabilityTrackingEvent.h>
#import <SCSCoreKitTV/SCSViewabilityTrackingEventManagerProtocol.h>
#import <SCSCoreKitTV/SCSViewabilityTrackingEventManager.h>

#import <SCSCoreKitTV/SCSViewabilityManagerProtocol.h>
#import <SCSCoreKitTV/SCSViewabilityManagerDelegate.h>
#import <SCSCoreKitTV/SCSViewabilityManager.h>
#import <SCSCoreKitTV/SCSViewabilityStatus.h>

// System
#import <SCSCoreKitTV/SCSAppInfo.h>
#import <SCSCoreKitTV/SCSAppInfoProtocol.h>

#import <SCSCoreKitTV/SCSIdentity.h>
#import <SCSCoreKitTV/SCSIdentityProviderProtocol.h>
#import <SCSCoreKitTV/SCSTransientID.h>

#import <SCSCoreKitTV/SCSDeviceInfo.h>
#import <SCSCoreKitTV/SCSAppInfoProtocol.h>
#import <SCSCoreKitTV/SCSDeviceInfoProviderProtocol.h>

#import <SCSCoreKitTV/SCSFrameworkInfo.h>
#import <SCSCoreKitTV/SCSFrameworkInfoProtocol.h>

#import <SCSCoreKitTV/SCSLocation.h>
#import <SCSCoreKitTV/SCSLocationManager.h>
#import <SCSCoreKitTV/SCSLocationManagerDataSource.h>
#import <SCSCoreKitTV/SCSLocationProviderDelegate.h>
#import <SCSCoreKitTV/SCSLocationProviderProtocol.h>

// Maths
#import <SCSCoreKitTV/SCSQuaternion.h>
#import <SCSCoreKitTV/SCSAxis3.h>
#import <SCSCoreKitTV/SCSAngleUtils.h>

// Config Manager
#import <SCSCoreKitTV/SCSRemoteConfigManager.h>
#import <SCSCoreKitTV/SCSRemoteConfigManagerDelegate.h>
#import <SCSCoreKitTV/SCSPropertyCacheManager.h>

// Model
#import <SCSCoreKitTV/SCSConfiguration.h>

// Logger
#import <SCSCoreKitTV/SCSLogNode.h>
#import <SCSCoreKitTV/SCSVASTErrorRemoteLoggerProtocol.h>
#import <SCSCoreKitTV/SCSLogVASTErrorNode.h>
#import <SCSCoreKitTV/SCSLogSDKNode.h>
#import <SCSCoreKitTV/SCSLogMeasureNode.h>
#import <SCSCoreKitTV/SCSLogErrorNode.h>
#import <SCSCoreKitTV/SCSRemoteLoggerProtocol.h>
#import <SCSCoreKitTV/SCSRemoteLogger.h>
#import <SCSCoreKitTV/SCSRemoteLog.h>
#import <SCSCoreKitTV/SCSRemoteLogUtils.h>
#import <SCSCoreKitTV/SCSRemoteConfigurationErrorRemoteLogger.h>
#import <SCSCoreKitTV/SCSLogOpenMeasurementNode.h>

// Network
#import <SCSCoreKitTV/SCSAdRequestManager.h>
#import <SCSCoreKitTV/SCSAdRequestValidatorProtocol.h>
#import <SCSCoreKitTV/SCSAdRequestErrors.h>

#import <SCSCoreKitTV/SCSNetworkInfo.h>
#import <SCSCoreKitTV/SCSNetworkInfoProtocol.h>

#import <SCSCoreKitTV/SCSScriptDownloader.h>
#import <SCSCoreKitTV/SCSScriptDownloaderDelegate.h>

#import <SCSCoreKitTV/SCSPixel.h>
#import <SCSCoreKitTV/SCSPixelManagerProtocol.h>
#import <SCSCoreKitTV/SCSPixelManager.h>
#import <SCSCoreKitTV/SCSPixelStore.h>
#import <SCSCoreKitTV/SCSPixelStoreProviderProtocol.h>

#import <SCSCoreKitTV/SCSURLSession.h>
#import <SCSCoreKitTV/SCSURLSessionResponse.h>
#import <SCSCoreKitTV/SCSURLSessionProviderProtocol.h>
#import <SCSCoreKitTV/SCSURLSessionTask.h>

// Utils
#import <SCSCoreKitTV/SCSUtils.h>
#import <SCSCoreKitTV/SCSUIUtils.h>
#import <SCSCoreKitTV/SCSURLUtils.h>
#import <SCSCoreKitTV/SCSStringUtils.h>
#import <SCSCoreKitTV/SCSHTMLUtils.h>
#import <SCSCoreKitTV/SCSTimeUtils.h>
#import <SCSCoreKitTV/SCSHash.h>
#import <SCSCoreKitTV/SCSRandom.h>
#import <SCSCoreKitTV/SCSLog.h>
#import <SCSCoreKitTV/SCSLogDataSource.h>
#import <SCSCoreKitTV/SCSLogOutput.h>
#import <SCSCoreKitTV/SCSProdURL.h>
#import <SCSCoreKitTV/SCSTimer.h>
#import <SCSCoreKitTV/SCSTimerInterval.h>
#import <SCSCoreKitTV/SCSTimerDelegate.h>
#import <SCSCoreKitTV/SCSFuture.h>
#import <SCSCoreKitTV/SCSTCFString.h>
#import <SCSCoreKitTV/SCSCCPAString.h>

//! Project version number for SCSCoreKitTV.
FOUNDATION_EXPORT double SCSCoreKitTVVersionNumber;

//! Project version string for SCSCoreKitTV.
FOUNDATION_EXPORT const unsigned char SCSCoreKitTVVersionString[];

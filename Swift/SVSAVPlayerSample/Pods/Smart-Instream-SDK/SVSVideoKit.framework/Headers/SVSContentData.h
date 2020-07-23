//
//  SVSContentData.h
//  SVSVideoKit
//
//  Created by Thomas Geley on 22/05/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Represents the details of the content video. Passed to the AdServer for targeting.
 This object should be passed to your instance of SVSAdManager during initialization.
 */
@interface SVSContentData : NSObject <NSCopying, NSCoding>

#pragma mark - Content data initialization

/**
 Initialize a SVSContentData instance. This class forwards information about the video content to the AdServer.
 
 @param contentID Identifier of the video content.
 @param contentTitle Name of the video content.
 @param videoContentType Type of the video content.
 @param videoContentCategory Category of the video content.
 @param videoContentDuration Duration of the video content (in seconds, as NSNumber).
 @param videoSeasonNumber Season number of the video content (as NSNumber).
 @param videoEpisodeNumber Episode number of the video content (as NSNumber).
 @param videoContentRating Permissible audiance for this video content.
 @param contentProviderID Provider identifier of the video content.
 @param contentProviderName Provider name of the video content.
 @param videoContentDistributorID Distributor identifier of the video content.
 @param videoContentDistributorName Distributor name of the video content.
 @param videoContentTags An array of keywords (as NSString) qualifying the video content.
 @param externalContentID Identifier of the video content for third party system.
 @param videoCMSID Identifier of management system in charge of the content.
 @return An initialized instance of SVSContentData.
 */
- (instancetype)initWithContentID:(nullable NSString *)contentID
                     contentTitle:(nullable NSString *)contentTitle
                 videoContentType:(nullable NSString *)videoContentType
             videoContentCategory:(nullable NSString *)videoContentCategory
             videoContentDuration:(nullable NSNumber *)videoContentDuration
                videoSeasonNumber:(nullable NSNumber *)videoSeasonNumber
               videoEpisodeNumber:(nullable NSNumber *)videoEpisodeNumber
               videoContentRating:(nullable NSString *)videoContentRating
                contentProviderID:(nullable NSString *)contentProviderID
              contentProviderName:(nullable NSString *)contentProviderName
        videoContentDistributorID:(nullable NSString *)videoContentDistributorID
      videoContentDistributorName:(nullable NSString *)videoContentDistributorName
                 videoContentTags:(nullable NSArray <NSString *> *)videoContentTags
                externalContentID:(nullable NSString *)externalContentID
                       videoCMSID:(nullable NSString *)videoCMSID NS_DESIGNATED_INITIALIZER;

#pragma mark - Read only properties

/// Identifier of the content video.
@property (nullable, nonatomic, readonly) NSString *contentID;

/// Name of the content video.
@property (nullable, nonatomic, readonly) NSString *contentTitle;

/// Type of the content video.
@property (nullable, nonatomic, readonly) NSString *videoContentType;

/// Category of the content video.
@property (nullable, nonatomic, readonly) NSString *videoContentCategory;

/// Duration of the content video (in seconds).
@property (nullable, nonatomic, readonly) NSNumber *videoContentDuration;

/// Season number of the content video.
@property (nullable, nonatomic, readonly) NSNumber *videoSeasonNumber;

/// Episode number of the content video.
@property (nullable, nonatomic, readonly) NSNumber *videoEpisodeNumber;

/// Permissible audiance of the content video (general audiences, parental guidance, adult, etc...).
@property (nullable, nonatomic, readonly) NSString *videoContentRating;

/// Identifier of the content provider.
@property (nullable, nonatomic, readonly) NSString *contentProviderID;

/// Name of the content provider.
@property (nullable, nonatomic, readonly) NSString *contentProviderName;

/// Identifier of the content distributor.
@property (nullable, nonatomic, readonly) NSString *videoContentDistributorID;

/// Name of the content distributor.
@property (nullable, nonatomic, readonly) NSString *videoContentDistributorName;

/// Array of keywords describing the content video.
@property (nullable, nonatomic, readonly) NSArray <NSString *> *videoContentTags;

/// Identifier of the content in a third party system.
@property (nullable, nonatomic, readonly) NSString *externalContentID;

/// Identifier of the video content management system in charge of the content.
@property (nullable, nonatomic, readonly) NSString *videoCMSID;


- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

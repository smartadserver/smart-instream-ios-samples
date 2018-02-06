//
//  SVSAdPlacement.h
//  SVSVideoKit
//
//  Created by Thomas Geley on 27/03/2017.
//  Copyright © 2017 Smart AdServer. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Enum that reference all type of ads you can get using the test mode.
 
 See the [SVSAdPlacement adPlacementForTestAd:] method documentation for more infos.
 */
typedef NS_ENUM(NSInteger, SVSAdPlacementTest) {
    
    /// A placement that will return ads for preroll, midroll and postroll
    SVSAdPlacementTestPrerollMidrollPostroll,
    
};

/**
 Class used to create instream video ad placement.
 */
@interface SVSAdPlacement : NSObject <NSCoding, NSCopying>

#pragma mark - Placement initialization

/**
 Initialize a new instance of SVSAdPlacement.
 
 @param siteId The siteId created on the Smart AdServer manage interface. Create a new site Id for every unique application on your network.
 @param pageId The pageId created on the Smart AdServer manage interface. It is recommanded to create a new page id for every unique screen in your application.
 @param formatId The formatId created on the Smart AdServer manage interface. It is recommanded to create a new format Id for every type of ad you will integrate in your application.
 
 @return An initialized instance of SVSAdPlacement.
 */
- (instancetype)initWithSiteId:(unsigned long)siteId pageId:(unsigned long)pageId formatId:(unsigned long)formatId;

/**
 Initialize a new instance of SVSAdPlacement.
 
 @param siteId The siteId created on the Smart AdServer manage interface. Create a new site Id for every unique application on your network.
 @param pageName The pageName created on the Smart AdServer manage interface. It is recommanded to create a new page name for every unique screen in your application.
 @param formatId The formatId created on the Smart AdServer manage interface. It is recommanded to create a new format Id for every type of ad you will integrate in your application.
 
 @return An initialized instance of SVSAdPlacement.
 */
- (instancetype)initWithSiteId:(unsigned long)siteId pageName:(nonnull NSString *)pageName formatId:(unsigned long)formatId;

/**
 Returns an initialized SVSAdPlacement object.
 
 @param siteId The siteId created on the Smart AdServer manage interface. Create a new site Id for every unique application on your network.
 @param pageId The pageId created on the Smart AdServer manage interface. It is recommanded to create a new page id for every unique screen in your application.
 @param formatId The formatId created on the Smart AdServer manage interface. It is recommanded to create a new format Id for every type of ad you will integrate in your application.
 
 @return An initialized instance of SVSAdPlacement.
 */
+ (instancetype)adPlacementWithSiteId:(unsigned long)siteId pageId:(unsigned long)pageId formatId:(unsigned long)formatId;

/**
 Returns an initialized SVSAdPlacement object.
 
 @param siteId The siteId created on the Smart AdServer manage interface. Create a new site Id for every unique application on your network.
 @param pageName The pageName created on the Smart AdServer manage interface. It is recommanded to create a new page name for every screen in your application.
 @param formatId The formatId created on the Smart AdServer manage interface. It is recommanded to create a new format Id for every type of ad you will integrate in your application.
 
 @return An initialized instance of SVSAdPlacement.
 */
+ (instancetype)adPlacementWithSiteId:(unsigned long)siteId pageName:(nonnull NSString *)pageName formatId:(unsigned long)formatId;

/**
 Returns an initialized SVSAdPlacement object corresponding to a test video ad breaks.
 
 A test video ad breaks will always deliver and will always be from a specific type.
 You can use these tests to verify that your integration will work properly with all types of ads.
 
 Available test video ad breaks are listed in the SVSAdPlacementTest object.
 
 @warning If you set a test placement, make sure to remove it before
 submitting your application to the App Store.
 
 @param type The type of ad breaks you want to get for ad calls.
 
 @return An initialized instance of SVSAdPlacement corresponding to a test video ad breaks.
 */
+ (instancetype)adPlacementForTestAd:(SVSAdPlacementTest)type;

#pragma mark - Targeting

/**
 * A string representing a set of keywords that will be passed to Smart AdServer to receive
 * more relevant advertising.
 *
 * Keywords are typically used to target ad campaign insertions at specific user segments. They should be
 * formatted as comma-separated key-value pairs (e.g. "gender=female,age=27").
 *
 * On the Smart AdServer manage interface, keyword targeting options can be found under the Targeting / Keywords
 * section when managing campaign insertions.
 *
 * The global targeting will be used if no targeting is set for a given Ad Break.
 */
@property (nonatomic, copy, nullable) NSString *globalKeywordsTargeting;

/**
 * A string representing a set of keywords that will be passed to Smart AdServer to receive
 * more relevant ads when performing an Ad call for a Preroll Ads.
 *
 * If null, the globalKeywordsTargeting will be used.
 */
@property (nonatomic, copy, nullable) NSString *preRollKeywordsTargeting;

/**
 * A string representing a set of keywords that will be passed to Smart AdServer to receive
 * more relevant ads when performing an Ad call for a Midroll Ads.
 *
 * If null, the globalKeywordsTargeting will be used.
 */
@property (nonatomic, copy, nullable) NSString *midRollKeywordsTargeting;

/**
 * A string representing a set of keywords that will be passed to Smart AdServer to receive
 * more relevant ads when performing an Ad call for a Postroll Ads.
 *
 * If null, the globalKeywordsTargeting will be used.
 */
@property (nonatomic, copy, nullable) NSString *postRollKeywordsTargeting;

#pragma mark - Placement properties

/// A Long representing the siteId that should be passed to Smart AdServer to receive advertising.
@property (nonatomic, readonly) unsigned long siteId;

/// A Long representing the page id (if page name is not set) that should be passed to Smart AdServer to receive advertising.
@property (nonatomic, readonly) unsigned long pageId;

/// A String representing the page name (if page id is not set) that should be passed to Smart AdServer to receive advertising.
@property (nonatomic, readonly, nullable) NSString *pageName;

/// A Long representing the format id that should be passed to Smart AdServer to receive instream advertising format.
@property (nonatomic, readonly) unsigned long formatId;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END


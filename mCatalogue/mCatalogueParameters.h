/****************************************************************************
 *                                                                           *
 *  Copyright (C) 2014-2015 iBuildApp, Inc. ( http://ibuildapp.com )         *
 *                                                                           *
 *  This file is part of iBuildApp.                                          *
 *                                                                           *
 *  This Source Code Form is subject to the terms of the iBuildApp License.  *
 *  You can obtain one at http://ibuildapp.com/license/                      *
 *                                                                           *
 ****************************************************************************/

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "functionLibrary.h"

#import "mCatalogueCart.h"
#import "mCatalogueUserProfile.h"
#import "mCatalogueConfirmInfo.h"

#import "IBURLLoader.h"

extern const NSString *mCatalogueOrderConfirmInfoKey;
extern const NSString *mCatalogueUserProfileKey;

/**
 * Enumeration of available types of facebook liked URLs loading.
 * Used to reattempt loading or synchronize loaded URL lists.
 */
typedef enum
{
  mCatalogueLikedFacebookItemsLoadingInProgress = 1,
  mCatalogueLikedFacebookItemsLoadingCompletedSuccessfully = 2,
  mCatalogueLikedFacebookItemsLoadingFailed = 3,
  mCatalogueLikedFacebookItemsLoadingNotStarted = 4
} mCatalogueLikedFacebookItemsLoadingState;

#if NS_BLOCKS_AVAILABLE
typedef void(^mCatalogueParametersSuccessBlock)(NSData *data);
typedef void(^mCatalogueParametersFailureBlock)(NSError *error);
#endif



@class mCatalogueDBManager;
@class mCatalogueCart;

/**
 *  Special class for module parameters
 */
@interface mCatalogueParameters : NSObject

/**
 *  Application ID
 */
@property(nonatomic, strong) NSString *appID;

/**
 *  Application Name
 */
@property(nonatomic, strong) NSString *appName;

/**
 *  Module ID
 */
@property(nonatomic, strong) NSString *moduleID;


/**
 *  Main screen (page) title
 */
@property(nonatomic, strong) NSString *pageTitle;

/**
 *  Array of categories
 */
@property(nonatomic, strong) NSMutableArray *categories;

/**
 *  String with 1\0 values for enabling\disabling buttons on item detail page
 */
@property(nonatomic, strong) NSString *enabledButtons;


/**
 *  Array of products out of categories
 */
@property(nonatomic, strong) NSMutableArray *products;

/**
 *  Currency code like USD, EUR, GBP
 */
@property(nonatomic, strong) NSString *currencyCode;

/**
 *  Page background color
 */
@property(nonatomic, strong) UIColor *backgroundColor;

/**
 *  Color of category title
 */
@property(nonatomic, strong) UIColor *categoryTitleColor;

/**
 *  Color of text headers
 */
@property(nonatomic, strong) UIColor *captionColor;

/**
 *  Text color
 */
@property(nonatomic, strong) UIColor *descriptionColor;

/**
 *  Color of price field
 */
@property(nonatomic, strong) UIColor *priceColor;

/**
 * <code>separatorColor</code> for UITableView representing list of items on the cart screen.
 */
-(UIColor *)cartSeparatorColor;

/**
 * "Submit" button color on the cart screen.
 */
-(UIColor *)cartSubmitButtonTextColor;

/**
 *  Use 24-hour time format
 */
@property(nonatomic, assign) BOOL normalFormatDate;

/**
 *  Add link to ibuildapp.com to sharing messages
 */
@property(nonatomic, assign) BOOL showLink;

/**
 * Flag, if <code>YES</code> -- module presentation style is Grid, otherwise - Row.
 */
@property(nonatomic, assign) BOOL isGrid;

/**
 *  Show images for categories
 */
@property(nonatomic, assign) BOOL showImages;

/**
 *  Show categories or show list of products immediately
 */
@property(nonatomic, assign) BOOL showCategories;

/**
 *  Database file path
 */
@property (nonatomic, readonly) NSString                  *dbFilePath;

/**
 *  Database manager
 */
@property (nonatomic, strong) mCatalogueDBManager               *dbManager;

/**
 * Liked items for current fb user
 */
@property (nonatomic, strong) NSMutableArray               *likedItems;

/**
 * Current facebook liked URLs list loading state.
 */
@property (nonatomic) mCatalogueLikedFacebookItemsLoadingState likedItemsLoadingState;

/**
 * Flag, tells whether the color1 in scheme is purely white.
 */
@property (nonatomic) BOOL isWhiteBackground;

/**
 * Shared instanse of mCatalogueParameters.
 */
+(instancetype)sharedParameters;

/**
 *  dbFilePath - get path to the database file
 *
 *  @param moduleID_ - module identifier string
 *
 *  @return database file full path or nil if path not exists
 */
+ (NSString *)dbFilePath:(NSString *)moduleID_;

/**
 * check whether database exists or not ?
 *
 *  @return YES - database exists, NO - database doesn't exists
 */
- (BOOL)dbExists;

/**
 * Check whether we have active Internet connection
 *
 * @return YES - if we are connected to the Internet
 */
- (BOOL)isInternetReachable;

/**
 * Sends cart contents as an order to iBuildApp server.
 *
 * @param userProfile_ - user-provided order info.
 * @param note_ - user-provided note to the order.
 * @param success_ - success block.
 * @param failure_ - failure block.
 */
- (void)sendOrderWithUserProfile:(mCatalogueUserProfile *)userProfile_
                            note:(mCatalogueUserProfileItem *)note_
                         success:(URLLoaderSuccessBlock)success_
                         failure:(URLLoaderFailureBlock)failure_;

/**
 * Formats userProfile and note as JSON string for sending to to iBuildApp server.
 *
 * @param userProfile_ - user-provided order info.
 * @param note_ - user-provided note to the order.
 *
 * @return success_ - JSON-formatted string.
 */
+ (NSString *)formatJSONRequestWithUserProfile:(mCatalogueUserProfile *)userProfile_
                                          note:(mCatalogueUserProfileItem *)note_;

/**
 * Serializes 2 most complex structures - UserProfile and ConfirmInfo.
 */
- (BOOL)serialize;

/**
 *  deserializeWithModuleID - restore configuration from serializable data.
 *
 *  In fact, deserializes 2 most complex structures - UserProfile and ConfirmInfo only.
 *
 *  @param  moduleID_ - module identifire string
 *
 *  @return deserializable object of <mShoppingCartConfig> type or nil if there was no serialized parameters
 */
+ (mCatalogueParameters *)deserializeParametersWithModuleID:(NSString *)moduleID;

/**
 * Fills self with values from the parameters.
 *
 * @param sourceParameters -- parameters for self to be filled with.
 */
-(void)fillWithParameters:(mCatalogueParameters *)parameters;

/**
 * Merchant id from PayPal.
 */
@property (nonatomic, retain) NSString *payPalClientId;

/**
 * App-scoped widget id.
 */
@property (nonatomic) NSInteger widgetId;

/**
 * Flag, tells if cart is enbled in catalogue.
 */
@property (nonatomic, assign) BOOL cartEnabled;

/**
 * Flag, tells checkout with PayPal is enbled in catalogue.
 */
@property (nonatomic, assign) BOOL checkoutEnabled;

/**
 * Endpoint to submit order if checkout with PayPal is disabled.
 */
@property (nonatomic, strong) NSString *orderEndpointURL;

/**
 * Object acting as container for user-provided note.
 */
@property (nonatomic, strong) mCatalogueConfirmInfo *confirmInfo;

/**
 * Object conatining user-providing order info.
 */
@property (nonatomic, strong) mCatalogueUserProfile *userProfile;

/**
 * Cart object user all over the module.
 */
@property (nonatomic, retain) mCatalogueCart *cart;

@end

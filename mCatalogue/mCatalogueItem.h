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

#import "mCatalogueParameters.h"
#import "mCatalogueEntry.h"

#import "IBPayments/IBPItem.h"

/**
 *  Data model for Catalogue item (product)
 */
@interface mCatalogueItem : mCatalogueEntry

/**
 *  True id from server. Do not use as primary key on device
 *  likely to be duplicated (due to one-to-many relationship between
 *  item and categories on server, represented as several items with same id, 
 *  but unique categories).
 */
@property(nonatomic) NSInteger pid;

/**
 *  Product description
 */
@property(nonatomic, strong) NSString *description;


/**
 *  Product description freed from html tags
 */
@property(nonatomic, strong) NSString *descriptionPlainText;

/**
 *  Product image thumbnail URL
 */
@property(nonatomic, strong) NSString *thumbnailUrl;

/**
 *  Name of built-in resource for product image thumbnail
 */
@property(nonatomic, strong) NSString *thumbnailUrlRes;

/**
 * Item sku
 */
@property(nonatomic, strong) NSString *sku;

/**
 * Item price
 */
@property(nonatomic, strong) NSDecimalNumber *price;

/**
 * Item old price
 */
@property(nonatomic, strong) NSDecimalNumber *oldPrice;

/**
 * The item formatted price. This is deprecated, as a model class must not involve view-related
 * issues.
 */
@property(nonatomic, strong, readonly) NSString *priceStr;

/**
 * Currency code of item's price.
 */
@property (nonatomic, readonly) NSString *currencyCode;

/**
 * Tells if an item has a thumbnail
 *
 * @return <code>YES</code> if there is an image, <code>NO</code> otherwise.
 */
-(BOOL)hasThumbnail;

/**
 * URL string for image to be displayed.
 *
 * @discussion
 * At this moment only valid image is item's full-sized image.
 * If you provide decent quality thumbnails, you better use those thumbnails.
 */
-(NSString *)imageUrlStringForThumbnail;

/**
 * Convenience method to convert mCatalogue item to IBPayments item.
 */
-(IBPItem *) asIBPItem;

/**
 * Returns formatted price with given currency code.
 *
 * @param aPrice - price as NSDecimalNumber.
 * @param currencyCode - currency code like "USD", "EUR" and so on.
 *
 * @return <code>NSNumberFormatterCurrencyStyle</code>-formatted price string.
 */
+(NSString *)formattedPriceStringForPrice:(NSDecimalNumber *)aPrice
                         withCurrencyCode:(NSString *)currencyCode;

/**
 * Format a price.
 *
 * @param price the price numeric value to format
 * @param currencyCode an international three-letter currency code to be used to determine the
 *        currency symbol.
 * @param emptyStringWhenZeroPrice return the empty string instead of the zero price representation.
 *
 * @return string representation of the price with the locale-dependent currency symbol.
 * 
 */
+ (NSString *)formattedPriceStringForPrice:(NSDecimalNumber *)price
                          withCurrencyCode:(NSString *)currencyCode
                  emptyStringWhenZeroPrice:(BOOL)emptyStringWhenZeroPrice;

@end

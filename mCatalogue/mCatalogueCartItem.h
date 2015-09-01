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
#import "IBPayments/IBPCartItem.h"

@class mCatalogueCartItem;

/**
 * Delegate for handling quantity changes of the item.
 *
 * @see mCatalogueCartItem
 */
@protocol mCatalogueCartItemDelegate<NSObject>
@optional
- (void)catalogueCartItem:(mCatalogueCartItem *)item
             didChangeCount:(NSInteger)newCount_
                   oldCount:(NSInteger)oldCount_;
@end


/**
 *  Catalogue Cart item
 */

@class mCatalogueItem;
@interface mCatalogueCartItem : NSObject

/**
 *  Cart product
 */
@property(nonatomic, strong) mCatalogueItem *item;

/**
 *  Amount of products in cart
 */
@property(nonatomic, assign) NSUInteger count;


/**
 *  Price of all CatalogueItems
 */
@property(nonatomic, strong, readonly) NSDecimalNumber *totalPrice;

/**
 *  Delegate
 */
@property(nonatomic, assign) id<mCatalogueCartItemDelegate> delegate;

- (id)initWithCatalogueItem:(mCatalogueItem *)item_
                      count:(NSUInteger)count_;

- (void)setCountWithString:(NSString *)value_;
- (void)setCountWithString:(NSString *)value_
                  validate:(BOOL)bValidate_;


+ (NSUInteger)countWithString:(NSString *)value_;

+ (NSUInteger)countWithString:(NSString *)value_
                     validate:(BOOL)bValidate_;

- (NSString *)countAsString;

/**
 *  JSON dictionary object representation
 *
 *  @return JSON dictionary
 */
- (NSDictionary *)jsonDictionary;

- (IBPCartItem *)asIBPCartItem;

@end
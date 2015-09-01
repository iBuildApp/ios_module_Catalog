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
#import "mCatalogueItem.h"
#import "mCatalogueCartItem.h"
#import "IBPayments/IBPCart.h"

@class mCatalogueCart;
@class mCatalogueCartItem;

/**
 * Delegate for handling quantity changes in the cart.
 *
 * @see mCatalogueCart
 */
@protocol mCatalogueCartDelegate<NSObject>
@optional

- (void)catalogueCart:(mCatalogueCart *)cart_
           didAddItem:(mCatalogueCartItem *)item_;

- (void)catalogueCart:(mCatalogueCart *)cart_
        didDeleteItem:(mCatalogueCartItem *)item_;

- (void)catalogueCart:(mCatalogueCart *)cart_
didChangeQuantityForItem:(mCatalogueCartItem *)item_
          oldQuantity:(NSInteger)oldQuantity
          newQuantity:(NSInteger)newQuantity;

@end


/**
 *  mCatalogueCart - represent current cart state
 */
@interface mCatalogueCart : NSObject<mCatalogueCartItemDelegate>

/**
 *  Delegate
 */
@property(nonatomic, assign) id<mCatalogueCartDelegate> delegate;

/**
 *  maximum summary field's length (number of symbols)
 *
 *  @return Maximum summary lenth
 */
+ (NSUInteger)maxSummaryLength;

/**
 *  order id
 */
@property(nonatomic, assign) NSInteger               uid;

/**
 *  order title
 */
@property(nonatomic, strong) NSString               *title;

/**
 *  order summary (brief description)
 */
@property(nonatomic, strong) NSString               *summary;

/**
 *  order date
 */
@property(nonatomic, strong) NSDate                 *date;

/**
 *  order total count
 */
@property(nonatomic, assign) NSUInteger               totalCount;

/**
 *  order status
 */
//@property(nonatomic, assign) CatalogueOrderStatus status;


/**
 *  Reset order state
 */
- (void)reset;

/**
 *  Add product with specified qty to cart
 *
 *  @param product_  Product
 *  @param quantity_ Quantity
 */
- (void)addCatalogueItem:(mCatalogueItem *)product_
      withQuantity:(NSInteger)quantity_;


/**
 *  Add several mCatalogueCartItem objects to cart
 *
 *  @param cartItems  Product
 */
- (void)addCartItems:(NSArray *)cartItems;

/**
 *  Get item at specified index
 *
 *  @param index_ Index
 *
 *  @return mCatalogueCartItem instance
 */
- (mCatalogueCartItem *)itemAtIndex:(NSUInteger)index_;

/**
 *  Array of order items
 *
 *  @return Array of order items
 */
- (NSArray *)allItems;

/**
 *  Remove specified item from cart
 *
 *  @param element_ mCatalogueCartItem
 */
- (void)removeItem:(mCatalogueCartItem *)element_;

/**
 *  Remove item with specified index from cart
 *
 *  @param index_ Index in array
 */
- (void)removeItemAtIndex:(NSUInteger)index_;

/**
 *  Clear cart
 */
- (void)removeAllCartItems;

/**
 *  fill the summary field
 */
- (void)formatSummary;

/**
 *  clear cart
 */
- (void)clear;

/**
 *  Saves to DB
 */
-(void)persist;

/**
 *  JSON object representation
 */
- (NSString *)jsonString;

/**
 *  Price for all items in cart.
 */
- (NSDecimalNumber *)totalPrice;

/**
 * Convenience method to convert an mCatalogueCart to IBPayments cart.
 */
- (IBPCart *)asIBPCart;

@end
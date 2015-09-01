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


#import <UIKit/UIKit.h>
#import "mCatalogueCart.h"
#import "mCatalogueCartItem.h"

/**
 * Cart price width
 */
typedef struct tagCatalogueCartPriceWidth
{
  CGFloat priceWidth;
  CGFloat costWidth;
  CGFloat qtyWidth;
}CatalogueCartPriceWidth;

/**
 * Cart price insets
 */
typedef struct tagCatalogueCartPriceInsets
{
  UIEdgeInsets priceInsets;
  UIEdgeInsets costInsets;
  UIEdgeInsets qtyInsets;
}CatalogueCartPriceInsets;



/**
 *  Extention for mCatalogueCart for calculating text width for price, cost and qty
 */
@interface mCatalogueCart (priceWidth)

- (CatalogueCartPriceWidth)maximumPriceWidthWithFont:(UIFont *)font;

+ (CatalogueCartPriceWidth)maximumPriceWidthCartItems:(NSArray *)items_
                                            priceFont:(UIFont *)priceFont_
                                              qtyFont:(UIFont *)qtyFont_
                                        priceFormater:(NSString *(^)(mCatalogueCartItem *item)) blockFormaterPrice_
                                         costFormater:(NSString *(^)(mCatalogueCartItem *item))blockFormaterCost_
                                          qtyFormater:(NSString *(^)(NSInteger qty))blockFormaterQty_;
@end

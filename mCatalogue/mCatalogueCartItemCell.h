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
#import "NRLabel.h"
#import "mCatalogueTextField.h"
#import "mCatalogueCartCell.h"

/**
 *  Customized UITableViewCell for products in cart
 */
@interface mCatalogueCartItemCell : mCatalogueCartCell

/**
 *  Get content margin
 *
 *  @return UIEdgeInsets
 */
+ (UIEdgeInsets)contentMargin;

/**
 *  Create mCatalogueCartProductCell instance
 *
 *  @param identifier Cell identifier
 *  @param design     mCatalogueDesign instance
 *  @param delegate_  Delegate
 *
 *  @return mCatalogueCartItemCell instance
 */
+ (mCatalogueCartItemCell *)createCellWithCellIdentifier:(NSString *)identifier
                                                       delegate:(id<NSObject>)delegate_;

/**
 *  Update content
 *
 *  @param item          mCatalogueCartItem
 *  @param design        mCatalogueDesign
 *  @param containImage_ Is there image or not
 */
- (void)updateContentWithItem:(mCatalogueCartItem *)item
                containImage:(BOOL)containImage_;

@end

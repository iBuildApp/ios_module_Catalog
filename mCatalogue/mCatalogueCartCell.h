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
#import "mCatalogueTextField.h"
#import "mCatalogueCartItem.h"
#import "NRLabel.h"

/**
 * Catalogue cart "Delete" button.
 */
@interface mCatalogueCartDeleteButton : UIButton
@end

/**
 *  Customized UITableViewCell, base class for cart cells
 */
@interface mCatalogueCartCell : UITableViewCell<UITextFieldDelegate>

/**
 *  Price label view
 */
@property(nonatomic, readonly) NRLabel                         *priceLabel;

/**
 *  Products count edit field
 */
@property(nonatomic, readonly) mCatalogueTextField          *amountField;

/**
 *  Delete product from cart button
 */
@property(nonatomic, readonly) mCatalogueCartDeleteButton *deleteButton;

/**
 *  Associated product data
 */
@property(nonatomic, strong  ) mCatalogueCartItem         *item;

/**
 *  Delegate
 */
@property(nonatomic, assign  ) id                     delegate;

/**
 *  Indicator of image existence
 */
@property(nonatomic, assign  ) BOOL                             containImage;

@end

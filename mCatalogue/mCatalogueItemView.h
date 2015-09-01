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

#import "NRGridViewCell.h"
#import "mCatalogueItem.h"
#import "mCatalogueEntryView.h"

#define kCatalogueItemCellWidth_Row 300.0f
#define kCatalogueItemCellHeight_Row 90.0f//110.0f

#define kCatalogueItemCellWidth_Grid 150.0f
#define kCatalogueItemCellHeight_Grid 220.0f


@class mCatalogueItemView;

/**
 * Delegate for handling actions, initiated on mCatalogueItemView
 *
 * @see mCatalogueItemView
 */
@protocol mCatalogueItemViewDelegate <NSObject>

@optional

/**
 * Handle tap on cart button.
 */
-(void)cartButtonPressed:(mCatalogueItemView *)sender;

@end

/**
 * View for single catalogue item.
 * Used in the list of items.
 */
@interface mCatalogueItemView : mCatalogueEntryView

/**
 * Catalogue item to display.
 */
@property (nonatomic, strong) mCatalogueItem *catalogueItem;

/**
 * Button to add catalogue item to cart.
 */
@property (nonatomic, strong) UIButton *cartButton;

/**
 * Show placeholder only if owning category has items with images.
 */
@property (nonatomic, setter=showPlaceholder:) BOOL shouldShowPlaceholder;

/**
 * mCatalogueItemView delegate.
 *
 * @see mCatalogueItemViewDelegate
 */
@property (nonatomic, assign) id<mCatalogueItemViewDelegate> delegate;

@end

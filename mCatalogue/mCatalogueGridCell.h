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
#import "mCatalogueEntryView.h"

#define kCatalogueCategoryViewMarginLeft_Grid 10.0f

/**
 * Custom UITableViewCell to display a pair of mCatalogueEntryViews in a line.
 *
 * @see mCatalogueEntryView
 */
@interface mCatalogueGridCell : UITableViewCell

/**
 * First view in a pair.
 */
@property (nonatomic, strong) mCatalogueEntryView *firstView;

/**
 * Optional second view in a pair.
 */
@property (nonatomic, strong) mCatalogueEntryView *secondView;

@end

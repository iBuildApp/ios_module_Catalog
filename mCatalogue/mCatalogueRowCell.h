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

#define kCatalogueTableRowGap_Row 6.0f

/**
 * Custom UITableViewCell to display a screen-wide mCatalogueEntryView
 * (one category view or one item view) in a row.
 *
 * @see mCatalogueEntryView
 */
@interface mCatalogueRowCell : UITableViewCell

/**
 * Category or item view to display.
 */
@property (nonatomic, strong) mCatalogueEntryView *catalogueEntryView;

@end

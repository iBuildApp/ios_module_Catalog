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
#import "mCatalogueCategory.h"
#import "mCatalogueEntryView.h"

#define kCatalogCategoryRowGap_Row 0.5f

#define kCatalogueCategoryCellWidth_Row 320.0f
#define kCatalogueCategoryCellHeight_Row 110.0f

#define kCatalogueCategoryCellWidth_Grid 150.0f
#define kCatalogueCategoryCellHeight_Grid 120.0f

#define kCatalogueCategoryCellSize_Row (CGSize){kCatalogueCategoryCellWidth_Row, kCatalogueCategoryCellHeight_Row}
#define kCatalogueCategoryCellSize_Grid (CGSize){kCatalogueCategoryCellWidth_Grid, kCatalogueCategoryCellHeight_Grid}

#define kCatalogueCategoryDarkMaskColor [[UIColor blackColor] colorWithAlphaComponent:0.2f]


/**
 * View for single catalogue category.
 * Used in the list of categories.
 */
@interface mCatalogueCategoryView : mCatalogueEntryView

/**
 * Catalogue category to display.
 */
@property (nonatomic, strong) mCatalogueCategory *catalogueCategory;

/**
 * Background color for category's imageview.
 * Shows as placeholder while category's image is not loaded.
 */
@property (nonatomic, strong) UIColor *imagePlaceholderMaskColor;

@end

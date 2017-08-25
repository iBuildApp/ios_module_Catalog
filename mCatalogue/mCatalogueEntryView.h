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
#import <SDWebImage/UIImageView+WebCache.h>
#import "mCatalogueParameters.h"

#define kCatalogueCellImageViewFadeInDuration 0.3f

#define kImagePlaceholderViewBackgroundColor [UIColor colorWithRed:163.0f/256.0f green:164.0f/256.0f blue:165.0f/256.0f alpha:1.0f]

/**
 * Catalogue entry view style.
 */
typedef enum {
  /**
   * Single row-wide view.
   */
  mCatalogueEntryViewStyleRow,
  
  /**
   * Pair of views in row.
   */
  mCatalogueEntryViewStyleGrid
} mCatalogueEntryViewStyle;

/**
 * Abstract class for item/category element in grid / row representation
 */
@interface mCatalogueEntryView : UIView
{
  /**
   * Block to fade in an image, when it is loaded with SDWebImage.
   */
  @protected SDWebImageSuccessBlock fadeInBlock;
}

/**
 * Initializes entry view with mCatalogueEntryViewStyle
 *
 * @see mCatalogueEntryViewStyle
 */
-(id) initWithCatalogueEntryViewStyle:(mCatalogueEntryViewStyle)style;

/**
 * Makes current view rasterized, making use of it in table views smooth
 */
-(void)makeScrollingEfficient;

/**
 * Discards rasterizing
 * @see makeScrollingEfficient
 */
-(void)makeInnerAnimationEfficient;

/**
 * Returns the size of the EntryView depending on it's style (row / grid).
 */
+ (CGSize)sizeForStyle:(mCatalogueEntryViewStyle)style;

/**
 * Current mCatalogueEntryViewStyle.
 */
@property (nonatomic, readonly) mCatalogueEntryViewStyle style;

/**
 * Catalogue parameters. Used by subclasses for getting colors from scheme.
 */
@property (nonatomic, strong) mCatalogueParameters *catalogueParameters;


@end

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

/**
 * mCatalogueEntry - abstract class for Catalogue items and categories
 */
@interface mCatalogueEntry : NSObject

/**
 *  Init with dictionary of parsed item/category parameters
 *
 *  @param categoryDict Dictionary of parsed parameters
 *
 *  @return Instance of type mCatalogueEntry or one of its descendants
 */
- (id)initWithDictionary:(NSDictionary *)dict_;

/**
 * Determines whether entry has any images, built-in or URL-provided.
 *
 * @return <code>YES</code> if there is an image, <code>NO</code> otherwise.
 */
- (BOOL)hasImage;

/**
 *  Entry UID
 */
@property(nonatomic) NSInteger uid;

/**
 *  Entry order in parent category
 */
@property(nonatomic) NSInteger order;

/**
 *  Entry's parent category UID
 */
@property(nonatomic) NSInteger parentCategoryUid;

/**
 *  Entry name
 */
@property(nonatomic, strong) NSString *name;

/**
 *  Entry image URL
 */
@property(nonatomic, strong) NSString *imgUrl;

/**
 *  Name of built-in resource for entry image
 */
@property(nonatomic, strong) NSString *imgUrlRes;

/**
 * Is entry valid?
 */
@property(nonatomic, assign, getter=isValid) BOOL valid;

/**
 * Is entry visible to customer?
 */
@property(nonatomic, assign, getter=isVisible) BOOL visible;

@end

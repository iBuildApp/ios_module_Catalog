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
#import "mCatalogueEntry.h"

/**
 *  Data model for menu category
 */
@interface mCatalogueCategory : mCatalogueEntry

/**
 *  Array of products
 */
@property(nonatomic, strong) NSArray *items;

/**
 *  Array of products
 */
@property(nonatomic, strong) NSArray *subcategories;

/**
 *  Show or hide images for products in category
 */
@property(nonatomic, assign) BOOL showItemsImgs;

@end

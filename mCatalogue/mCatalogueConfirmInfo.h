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
#import "TBXML.h"
#import "mCatalogueUserProfile.h"

/**
 *  Object for shopping cart confirmation info
 */
@interface mCatalogueConfirmInfo : NSObject<NSCopying,NSCoding>

/**
 *  User profile item
 */
@property(nonatomic, strong) mCatalogueUserProfileItem *note;

/**
 *  Title
 */
@property(nonatomic, strong) NSString *title;

/**
 *  Сonfirmation text
 */
@property(nonatomic, strong) NSString *text;

/**
 * Returns mCatalogueConfirmInfo created from xml element.
 */
+ (mCatalogueConfirmInfo *)createWithXMLElement:(TBXMLElement *)element_;

/**
 * Initializes mCatalogueConfirmInfo created from xml element.
 */
- (id)initWithXMLElement:(TBXMLElement *)element;

@end
